import 'package:url_launcher/url_launcher.dart';

// URL을 사파리 브라우저에서 여는 함수
Future<void> openInSafari(String urlString) async {
  final Uri url = Uri.parse(urlString);
  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView, // 사파리 창에서 URL을 엽니다.
    );
  } else {
    throw 'Could not launch $urlString';
  }
}
