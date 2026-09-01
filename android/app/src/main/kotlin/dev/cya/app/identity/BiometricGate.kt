package dev.cya.app.identity

import android.app.Activity
import android.content.Context
import android.hardware.biometrics.BiometricManager
import android.hardware.biometrics.BiometricPrompt
import android.os.Build
import android.os.CancellationSignal
import java.util.concurrent.Executor

/**
 * The fingerprint prompt behind the app lock (ADR-010).
 *
 * Uses the **framework** `BiometricPrompt` rather than `androidx.biometric` or the `local_auth`
 * plugin. Both alternatives would have pulled AppCompat into an app whose activity themes are
 * plain `Theme.*.NoTitleBar`, and re-parenting those themes to satisfy a dialog would have touched
 * the launch background every capture surface renders against. The framework prompt needs no
 * dependency and no theme change; the cost is that it starts at API 28, and anything older simply
 * does not see the option and uses its PIN. That is the correct degradation — biometrics are a way
 * to skip typing the PIN, never a replacement for having one.
 */
internal object BiometricGate {

    /** Matches `BiometricAvailability` on the Dart side. */
    fun availability(context: Context): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return "unavailable"
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            // API 28 has the prompt but not BiometricManager. Fingerprint hardware is the only
            // modality that existed, so its presence is the whole answer available to us.
            @Suppress("DEPRECATION")
            val hasHardware = context.packageManager.hasSystemFeature(
                android.content.pm.PackageManager.FEATURE_FINGERPRINT,
            )
            return if (hasHardware) "ready" else "unavailable"
        }

        val manager = context.getSystemService(BiometricManager::class.java)
            ?: return "unavailable"
        @Suppress("DEPRECATION")
        return when (manager.canAuthenticate()) {
            BiometricManager.BIOMETRIC_SUCCESS -> "ready"
            // Hardware is there but nothing is enrolled. Reported separately so the setup screen
            // can point at system settings instead of silently hiding the switch.
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> "not_enrolled"
            else -> "unavailable"
        }
    }

    /**
     * Shows the prompt and reports success through [onResult], exactly once.
     *
     * A cancel and a failure are both `false`: the caller's next move is identical either way —
     * leave the PIN keypad on screen and say nothing.
     */
    fun authenticate(
        activity: Activity,
        title: String,
        subtitle: String,
        negativeLabel: String,
        onResult: (Boolean) -> Unit,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            onResult(false)
            return
        }

        // The framework delivers callbacks on this executor; the main looper keeps the result on
        // the same thread the MethodChannel replies from.
        val executor = Executor { command -> activity.runOnUiThread(command) }
        var settled = false
        val settle = { success: Boolean ->
            if (!settled) {
                settled = true
                onResult(success)
            }
        }

        val prompt = BiometricPrompt.Builder(activity)
            .setTitle(title)
            .setSubtitle(subtitle)
            // The negative button is the way back to the PIN, so it is never omitted — a prompt
            // with no exit on a device whose sensor has stopped reading is a locked-out user.
            .setNegativeButton(negativeLabel, executor) { _, _ -> settle(false) }
            .build()

        prompt.authenticate(
            CancellationSignal(),
            executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(
                    result: BiometricPrompt.AuthenticationResult,
                ) = settle(true)

                /** Terminal: lockout, cancellation, no hardware. The prompt is gone. */
                override fun onAuthenticationError(code: Int, message: CharSequence) =
                    settle(false)

                // A single unrecognised finger is *not* terminal — the prompt stays up and the
                // user tries again, so nothing is reported here.
            },
        )
    }
}
