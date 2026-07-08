package com.example.cya

import android.animation.ObjectAnimator
import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.SurfaceTexture
import android.graphics.drawable.GradientDrawable
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.TypedValue
import android.view.Gravity
import android.view.Surface
import android.view.TextureView
import android.view.View
import android.widget.FrameLayout
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Native, pre-Flutter animated splash (PRD §5.2). Plays `res/raw/cya_splash`
 * in a compact circle-cropped card (center-cropped, muted) on a [TextureView], then hands off to
 * [MainActivity]. Designed to be flash-free: the window background is the still
 * first frame, the video is alpha-revealed only once it starts rendering, and
 * the destination engine is pre-warmed in [CyaApplication].
 *
 * Every exit path funnels through the idempotent [proceed]: normal completion,
 * playback error, a safety timeout, tap-to-skip, and reduced-motion.
 */
class SplashActivity : Activity(), TextureView.SurfaceTextureListener {

    private var mediaPlayer: MediaPlayer? = null
    private var textureView: TextureView? = null
    private var rootView: FrameLayout? = null
    private var playbackSurface: Surface? = null
    private val handedOff = AtomicBoolean(false)
    private val timeoutHandler = Handler(Looper.getMainLooper())
    private var videoWidth = 0
    private var videoHeight = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableImmersiveMode()

        // Honor "remove animations" / reduced motion by skipping the video.
        if (isReducedMotion()) {
            proceed()
            return
        }

        val texture = TextureView(this).apply {
            alpha = 0f
            surfaceTextureListener = this@SplashActivity
        }
        textureView = texture

        val videoCard = FrameLayout(this).apply {
            clipToOutline = true
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.TRANSPARENT)
            }
            elevation = dp(12).toFloat()
            addView(
                texture,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT,
                ),
            )
        }

        val root = FrameLayout(this).apply {
            setBackgroundColor(getColor(R.color.brand_splash))
            addView(
                videoCard,
                FrameLayout.LayoutParams(
                    splashVideoWidthPx(),
                    splashVideoHeightPx(),
                    Gravity.CENTER,
                ),
            )
            setOnClickListener { proceed() } // tap to skip
        }
        rootView = root
        setContentView(root)

        timeoutHandler.postDelayed({ proceed() }, SAFETY_TIMEOUT_MS)
    }

    // --- SurfaceTextureListener ---

    override fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int) {
        startPlayback(Surface(surface))
        updateTransform(width, height)
    }

    override fun onSurfaceTextureSizeChanged(surface: SurfaceTexture, width: Int, height: Int) {
        updateTransform(width, height)
    }

    override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean {
        releasePlayer()
        return true
    }

    override fun onSurfaceTextureUpdated(surface: SurfaceTexture) = Unit

    // --- Playback ---

    private fun startPlayback(surface: Surface) {
        try {
            playbackSurface = surface
            val afd = resources.openRawResourceFd(R.raw.cya_splash)
            val player = MediaPlayer()
            mediaPlayer = player
            player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            afd.close()
            player.setSurface(surface)
            player.setVolume(0f, 0f)
            player.setOnVideoSizeChangedListener { _, width, height ->
                videoWidth = width
                videoHeight = height
                textureView?.let { updateTransform(it.width, it.height) }
            }
            player.setOnInfoListener { _, what, _ ->
                if (what == MediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START) {
                    revealVideo()
                }
                false
            }
            player.setOnCompletionListener { proceed() }
            player.setOnErrorListener { _, _, _ ->
                proceed()
                true
            }
            player.setOnPreparedListener {
                it.start()
                timeoutHandler.postDelayed({ proceed() }, PLAYBACK_LIMIT_MS)
            }
            player.prepareAsync()
        } catch (t: Throwable) {
            proceed()
        }
    }

    private fun revealVideo() {
        val view = textureView ?: return
        if (view.alpha >= 1f) return
        ObjectAnimator.ofFloat(view, View.ALPHA, 0f, 1f).apply {
            duration = REVEAL_DURATION_MS
            start()
        }
    }

    /** Scales the (stretched) TextureView content up to center-crop the video. */
    private fun updateTransform(viewWidth: Int, viewHeight: Int) {
        val view = textureView ?: return
        if (viewWidth == 0 || viewHeight == 0 || videoWidth == 0 || videoHeight == 0) return
        val scale = maxOf(
            viewWidth.toFloat() / videoWidth,
            viewHeight.toFloat() / videoHeight,
        ) * VIDEO_CONTENT_SCALE
        val scaledWidth = videoWidth * scale
        val scaledHeight = videoHeight * scale
        val matrix = Matrix().apply {
            setScale(
                scaledWidth / viewWidth,
                scaledHeight / viewHeight,
                viewWidth / 2f,
                viewHeight / 2f,
            )
        }
        view.setTransform(matrix)
    }

    private fun splashVideoSizePx(): Int {
        val horizontalMargin = dp(64)
        val maxWidth = resources.displayMetrics.widthPixels - horizontalMargin
        return minOf(dp(300), maxWidth)
    }

    private fun splashVideoWidthPx(): Int = splashVideoSizePx()

    private fun splashVideoHeightPx(): Int = splashVideoSizePx()

    private fun dp(value: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            value.toFloat(),
            resources.displayMetrics,
        ).toInt()
    }

    // --- Handoff ---

    private fun proceed() {
        if (!handedOff.compareAndSet(false, true)) return
        timeoutHandler.removeCallbacksAndMessages(null)
        detachSplashView()
        startActivity(
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION),
        )
        disableTransition()
        finish()
        releasePlayer()
    }

    private fun detachSplashView() {
        textureView?.surfaceTextureListener = null
        textureView?.alpha = 0f
        rootView?.removeAllViews()
        textureView = null
        rootView = null
    }

    private fun releasePlayer() {
        val player = mediaPlayer ?: return
        val surface = playbackSurface
        mediaPlayer = null
        playbackSurface = null
        Thread {
            try {
                player.release()
            } catch (_: IllegalStateException) {
                // Player is already leaving a valid state; release is best-effort.
            } finally {
                surface?.release()
            }
        }.start()
    }

    @Suppress("DEPRECATION")
    private fun disableTransition() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            overrideActivityTransition(Activity.OVERRIDE_TRANSITION_OPEN, 0, 0)
        } else {
            overridePendingTransition(0, 0)
        }
    }

    private fun enableImmersiveMode() {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        WindowInsetsControllerCompat(window, window.decorView).apply {
            hide(WindowInsetsCompat.Type.systemBars())
            systemBarsBehavior =
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
    }

    private fun isReducedMotion(): Boolean {
        val scale = Settings.Global.getFloat(
            contentResolver,
            Settings.Global.ANIMATOR_DURATION_SCALE,
            1f,
        )
        return scale == 0f
    }

    // --- Lifecycle ---

    override fun onPause() {
        super.onPause()
        if (!handedOff.get()) {
            mediaPlayer?.let { if (it.isPlaying) it.pause() }
        }
    }

    override fun onResume() {
        super.onResume()
        mediaPlayer?.let { if (!handedOff.get() && !it.isPlaying) it.start() }
    }

    override fun onDestroy() {
        timeoutHandler.removeCallbacksAndMessages(null)
        detachSplashView()
        releasePlayer()
        super.onDestroy()
    }

    private companion object {
        const val SAFETY_TIMEOUT_MS = 2400L
        const val PLAYBACK_LIMIT_MS = 1700L
        const val REVEAL_DURATION_MS = 120L
        const val VIDEO_CONTENT_SCALE = 1.06f
    }
}
