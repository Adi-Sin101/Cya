package dev.cya.app.capture

import java.util.Calendar

/**
 * The zero-tap default reminder (PRD §6.1, §6.2), ported from
 * `lib/domain/enums/reminder_preset.dart`.
 *
 * A promise captured from the Share Sheet and one captured in the app must land on the *same*
 * instant, so these rules are duplicated deliberately and pinned in docs/native_db_contract.md.
 * `Calendar` rather than `java.time` so no desugaring is needed on the capture path.
 */
internal object ReminderDefaults {

    /** Today 20:00; if it is already 20:00 or later, now + 2h. */
    fun tonight(nowMillis: Long): Long {
        val tonight = Calendar.getInstance().apply {
            timeInMillis = nowMillis
            set(Calendar.HOUR_OF_DAY, 20)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis
        return if (nowMillis < tonight) tonight else nowMillis + TWO_HOURS_MILLIS
    }

    /** Tomorrow 09:00. */
    fun tomorrow(nowMillis: Long): Long = Calendar.getInstance().apply {
        timeInMillis = nowMillis
        add(Calendar.DAY_OF_YEAR, 1)
        set(Calendar.HOUR_OF_DAY, 9)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }.timeInMillis

    /** The next Saturday 10:00 (today if it is Saturday before 10:00). */
    fun weekend(nowMillis: Long): Long {
        val calendar = Calendar.getInstance().apply {
            timeInMillis = nowMillis
            set(Calendar.HOUR_OF_DAY, 10)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val todayAtTen = calendar.timeInMillis
        val isSaturday = calendar.get(Calendar.DAY_OF_WEEK) == Calendar.SATURDAY
        if (isSaturday && nowMillis < todayAtTen) return todayAtTen

        var daysUntilSaturday = (Calendar.SATURDAY - calendar.get(Calendar.DAY_OF_WEEK) + 7) % 7
        if (daysUntilSaturday == 0) daysUntilSaturday = 7
        calendar.add(Calendar.DAY_OF_YEAR, daysUntilSaturday)
        return calendar.timeInMillis
    }

    private const val TWO_HOURS_MILLIS = 2L * 60 * 60 * 1000
}
