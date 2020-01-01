package novy.vip.novynaplo
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import com.google.ads.consent.*

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    checkAdConsent()
    MethodChannel(flutterView, "consent.sdk/consent").setMethodCallHandler {
      // Note: this method is invoked on the main thread.
      call, result ->
      if (call.method == "setConsent") {
        result.success(call.argument("data"))
      } else {
        result.success(call.argument("data"))
        //result.notImplemented() Commented out to see if this caused the error, but it didn't
      }
    }
  }

  private fun checkAdConsent() {
    val consentInformation = ConsentInformation.getInstance(this)
    val publisherIds = Array(1, { "pub-6768960612393878" })
    consentInformation.requestConsentInfoUpdate(publisherIds, object : ConsentInfoUpdateListener {
      override fun onConsentInfoUpdated(consentStatus: ConsentStatus) {
        /*when (consentStatus) {
          ConsentStatus.PERSONALIZED -> loadAds(true)
          ConsentStatus.NON_PERSONALIZED -> loadAds(false)
          ConsentStatus.UNKNOWN -> displayConsentForm()
        }*/
      }

      override fun onFailedToUpdateConsentInfo(errorDescription: String) {
        //TODO make this work
      }
    })
  }
}
