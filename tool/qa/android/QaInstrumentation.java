package dev.cya.qafixture;

import android.app.Instrumentation;
import android.app.UiAutomation;
import android.graphics.Rect;
import android.os.Bundle;
import android.util.Base64;
import android.util.Xml;
import android.view.accessibility.AccessibilityNodeInfo;
import java.io.StringWriter;
import org.xmlpull.v1.XmlSerializer;

/** Public Android accessibility API only; never loads or instruments Cya code. */
public final class QaInstrumentation extends Instrumentation {
    private Bundle args;
    @Override public void onCreate(Bundle arguments) { super.onCreate(arguments); args=arguments; start(); }
    @Override public void onStart() {
        Bundle result=new Bundle();
        try {
            UiAutomation ui=getUiAutomation(UiAutomation.FLAG_DONT_SUPPRESS_ACCESSIBILITY_SERVICES);
            Thread.sleep(250);
            AccessibilityNodeInfo root=ui.getRootInActiveWindow();
            if(root==null) throw new IllegalStateException("No active accessibility window");
            if(args.containsKey("input")) {
                int[] index={Integer.parseInt(args.getString("index","0"))};
                if(!setText(root,index,new String(Base64.decode(args.getString("input"),Base64.DEFAULT),"UTF-8")))
                    throw new IllegalStateException("Editable accessibility action refused");
                Thread.sleep(200);
            }
            StringWriter out=new StringWriter();
            XmlSerializer xml=Xml.newSerializer();xml.setOutput(out);xml.startDocument("UTF-8",true);
            xml.startTag(null,"hierarchy");write(xml,root);xml.endTag(null,"hierarchy");xml.endDocument();
            result.putString("tree",Base64.encodeToString(out.toString().getBytes("UTF-8"),Base64.NO_WRAP));
            finish(-1,result);
        } catch(Exception error) { result.putString("error",error.toString());finish(1,result); }
    }
    private void write(XmlSerializer xml,AccessibilityNodeInfo n) throws Exception {
        xml.startTag(null,"node");
        xml.attribute(null,"text",value(n.getText()));
        xml.attribute(null,"content-desc",value(n.getContentDescription()));
        xml.attribute(null,"class",value(n.getClassName()));
        xml.attribute(null,"package",value(n.getPackageName()));
        xml.attribute(null,"resource-id",value(n.getViewIdResourceName()));
        xml.attribute(null,"clickable",String.valueOf(n.isClickable()));
        xml.attribute(null,"enabled",String.valueOf(n.isEnabled()));
        xml.attribute(null,"scrollable",String.valueOf(n.isScrollable()));
        Rect b=new Rect();n.getBoundsInScreen(b);
        xml.attribute(null,"bounds","["+b.left+","+b.top+"]["+b.right+","+b.bottom+"]");
        for(int i=0;i<n.getChildCount();i++){ AccessibilityNodeInfo c=n.getChild(i);if(c!=null){write(xml,c);c.recycle();} }
        xml.endTag(null,"node");
    }
    private String value(CharSequence s){return s==null?"":s.toString();}
    private boolean setText(AccessibilityNodeInfo n,int[] remaining,String text) {
        if(n.isEditable() && remaining[0]--==0) {
            Bundle value=new Bundle();value.putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE,text);
            return n.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT,value);
        }
        for(int i=0;i<n.getChildCount();i++){AccessibilityNodeInfo c=n.getChild(i);if(c!=null){boolean done=setText(c,remaining,text);c.recycle();if(done)return true;}}
        return false;
    }
}
