package dev.cya.qafixture;

import android.app.Activity;
import android.appwidget.AppWidgetHost;
import android.appwidget.AppWidgetHostView;
import android.appwidget.AppWidgetManager;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Base64;
import android.widget.TextView;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

/** Emulator-only offline interoperability fixture. Never bundled with Cya!. */
public final class FixtureActivity extends Activity {
  private AppWidgetHost host;
  private int widgetId;
  @Override public void onCreate(Bundle state) {
    super.onCreate(state);
    try {
      Intent intent = getIntent();
      String mode = intent.getStringExtra("mode");
      if ("clipboard".equals(mode) || "share".equals(mode)) {
        String text = new String(Base64.decode(intent.getStringExtra("base64"), Base64.DEFAULT), StandardCharsets.UTF_8);
        if ("clipboard".equals(mode)) {
          getSystemService(ClipboardManager.class).setPrimaryClip(ClipData.newPlainText("Synthetic Cya QA", text));
        } else {
          startActivity(new Intent(Intent.ACTION_SEND).setType("text/plain")
            .setComponent(new ComponentName("dev.cya.app", "dev.cya.app.capture.CaptureActivity"))
            .putExtra(Intent.EXTRA_TEXT, text));
        }
        finish(); return;
      }
      if ("widget".equals(mode)) {
        host = new AppWidgetHost(this, 20261023); host.startListening();
        widgetId = getPreferences(0).getInt("widgetId", 0);
        if (widgetId == 0) { widgetId = host.allocateAppWidgetId(); getPreferences(0).edit().putInt("widgetId",widgetId).apply(); }
        ComponentName provider = new ComponentName("dev.cya.app", "dev.cya.app.widget.CyaWidgetProvider");
        AppWidgetManager manager = AppWidgetManager.getInstance(this);
        if (manager.getAppWidgetInfo(widgetId) != null || manager.bindAppWidgetIdIfAllowed(widgetId, provider)) showWidget();
        else startActivityForResult(new Intent(AppWidgetManager.ACTION_APPWIDGET_BIND)
          .putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
          .putExtra(AppWidgetManager.EXTRA_APPWIDGET_PROVIDER, provider), 1);
        return;
      }
      if (Intent.ACTION_SEND.equals(intent.getAction())) {
        Uri uri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
        if (uri == null) throw new IllegalArgumentException("Missing export stream");
        File output = new File(getExternalFilesDir(null), "application/zip".equals(intent.getType()) ? "received.zip" : "received.json");
        long bytes = 0;
        try (InputStream in = getContentResolver().openInputStream(uri); FileOutputStream out = new FileOutputStream(output)) {
          byte[] buffer = new byte[65536]; int size;
          while ((size = in.read(buffer)) != -1) { bytes += size; out.write(buffer, 0, size); }
          out.getFD().sync();
        }
        text("QA export received: " + bytes + " bytes"); return;
      }
      text("Cya QA fixture ready");
    } catch (Exception error) { text("QA fixture error: " + error.getClass().getSimpleName()); }
  }
  private void showWidget() {
    AppWidgetManager manager = AppWidgetManager.getInstance(this);
    AppWidgetHostView view = host.createView(this, widgetId, manager.getAppWidgetInfo(widgetId));
    view.setPadding(24, 80, 24, 24); setContentView(view);
  }
  @Override protected void onActivityResult(int request, int result, Intent data) {
    super.onActivityResult(request, result, data);
    if (request == 1 && result == RESULT_OK) showWidget(); else text("QA widget binding declined");
  }
  @Override protected void onDestroy() { if (host != null) host.stopListening(); super.onDestroy(); }
  private void text(String value) { TextView view = new TextView(this); view.setTextSize(20); view.setPadding(24,80,24,24); view.setText(value); setContentView(view); }
}
