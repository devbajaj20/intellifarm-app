import 'package:shared_preferences/shared_preferences.dart';

class AppStrings {
  static String _lang = 'en-IN';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('app_language') ?? 'en-IN';
  }

  static String text(String key) {
    // If language map missing → fallback to English
    final langMap = _localizedValues[_lang] ?? _localizedValues['en-IN'];

    // If key missing → show key itself (no crash)
    return langMap?[key]
        ?? _localizedValues['en-IN']?[key]
        ?? key;
  }
}

/// 🌍 TRANSLATIONS (6 LANGUAGES)
final Map<String, Map<String, String>> _localizedValues = {
  'en-IN': {
    'hello': 'Hello',
    'welcome_back': 'Welcome Back!',
    'login_account': 'Login Account',
    'login_subtitle': 'Enter your credentials to continue',
    'email': 'Email Address',
    'email_required': 'Email required',
    'email_invalid': 'Enter valid email',
    'password': 'Password',
    'password_min': 'Minimum 6 characters',
    'forgot_password': 'Forgot Password?',
    'login_with_otp': 'Login with OTP',
    'continue_google': 'Continue with Google',
    'create_account': 'Create New Account',
    'login_admin': 'Login as Admin',
    'invalid_login': 'Invalid email or password',
    'splash_title': 'IntelliFarm',
    'splash_tagline': 'Smart Farming • Better Yield',
    // App bar
    'welcome': 'Welcome to IntelliFarm',

    // Search
    'search_hint': 'Search here... ',

    // Advisory
    'read': 'Read',
    'critical': 'CRITICAL',

    // Modules
    'crop_recommendation': 'Crop Recommendation',
    'disease_detection': 'Disease Detection',
    'yield_prediction': 'Yield Prediction',
    'fertilizer': 'Fertilizer Suggestion',
    'marketplace': 'Marketplace',
    'weather': 'Weather Advisory',
    'loans': 'Loans & Schemes',
    'ai_chatbot': 'AI Chatbot',

    // Bottom navigation
    'home': 'Home',
    'ai': 'AI',
    'dashboard': 'Dashboard',
    'more': 'More',
    'join_us': 'Join Us',
    'create_account_signup_page': 'Create New Account',
    'signup_title': 'Create New Account',
    'signup_subtitle': 'Sign up to start using IntelliFarm',

    'email_signup': 'Email Address',
    'email_required_signup': 'Email required',
    'email_invalid_signup': 'Enter valid email',

    'password_signup': 'Password',
    'password_min_signup': 'Minimum 6 characters',

    'signup_phone': 'Sign up with Phone (OTP)',
    'already_account': 'Already have an account? Login',
    'reset_password': 'Reset Password',
    'forgot_title': 'Forgot Password?',
    'forgot_subtitle': 'Enter your email to receive reset link',
    'send_reset_link': 'Send Reset Link',
    'reset_email_sent': 'Reset link sent to your email',


    //not done yet
      "my_dashboard": "My Dashboard",
      "add_your_crop": "Add Your Crop",
      "add_crop_desc": "Start by adding your crop and sowing date to track progress.",
      "select_crop": "Select Crop",
      "choose_crop": "Choose your crop",
      "sowing_date": "Sowing Date",
      "select_date": "Select date",
      "save_crop": "Save Crop",
      "crop_progress": "Crop Progress",
      "add_crop": "Add Crop",
      "edit_crop": "Edit Crop",
      "save": "Save",
    "temperature": "Temperature",
    "humidity": "Humidity",
    "rainfall": "Rainfall",
      "weather": "Weather"

  },

  'hi-IN': {
    'hello': 'नमस्ते',
    'welcome_back': 'वापस स्वागत है!',
    'login_account': 'लॉगिन करें',
    'login_subtitle': 'जारी रखने के लिए विवरण भरें',
    'email': 'ईमेल पता',
    'email_required': 'ईमेल आवश्यक है',
    'email_invalid': 'मान्य ईमेल दर्ज करें',
    'password': 'पासवर्ड',
    'password_min': 'कम से कम 6 अक्षर',
    'forgot_password': 'पासवर्ड भूल गए?',
    'login_with_otp': 'OTP से लॉगिन',
    'continue_google': 'Google से जारी रखें',
    'create_account': 'नया खाता बनाएं',
    'login_admin': 'एडमिन लॉगिन',
    'invalid_login': 'गलत ईमेल या पासवर्ड',
    'splash_title': 'इंटेलीफार्म',
    'splash_tagline': 'स्मार्ट खेती • बेहतर उत्पादन',
    'welcome': 'इंटेलीफार्म में आपका स्वागत है',

    'search_hint': 'फसल, रोग, मौसम खोजें',

    'read': 'पढ़ें',
    'critical': 'महत्वपूर्ण',

    'crop_recommendation': 'फसल सिफारिश',
    'disease_detection': 'रोग पहचान',
    'yield_prediction': 'उपज पूर्वानुमान',
    'fertilizer': 'उर्वरक सुझाव',
    'marketplace': 'बाज़ार',
    'weather': 'मौसम सलाह',
    'loans': 'ऋण और योजनाएँ',
    'ai_chatbot': 'एआई चैटबॉट',

    'home': 'होम',
    'ai': 'एआई',
    'dashboard': 'डैशबोर्ड',
    'more': 'अधिक',
    'join_us': 'हमसे जुड़ें',
    'create_account_signup_page': 'खाता बनाएं',
    'signup_title': 'नया खाता बनाएं',
    'signup_subtitle': 'इंटेलीफार्म उपयोग शुरू करें',

    'email_signup': 'ईमेल पता',
    'email_required_signup': 'ईमेल आवश्यक है',
    'email_invalid_signup': 'मान्य ईमेल दर्ज करें',

    'password_signup': 'पासवर्ड',
    'password_min_signup': 'कम से कम 6 अक्षर',

    'signup_phone': 'फोन (OTP) से साइनअप',
    'already_account': 'पहले से खाता है? लॉगिन करें',
    'reset_password': 'पासवर्ड रीसेट करें',
    'forgot_title': 'पासवर्ड भूल गए?',
    'forgot_subtitle': 'रीसेट लिंक पाने के लिए अपना ईमेल दर्ज करें',
    'send_reset_link': 'रीसेट लिंक भेजें',
    'reset_email_sent': 'रीसेट लिंक आपके ईमेल पर भेज दिया गया है',

  },

  'or-IN': {
    'reset_password': 'ପାସୱାର୍ଡ ପୁନଃସେଟ୍ କରନ୍ତୁ',
    'forgot_title': 'ପାସୱାର୍ଡ ଭୁଲିଗଲେ?',
    'forgot_subtitle': 'ରିସେଟ୍ ଲିଙ୍କ ପାଇବାକୁ ଆପଣଙ୍କ ଇମେଲ୍ ଦିଅନ୍ତୁ',
    'send_reset_link': 'ରିସେଟ୍ ଲିଙ୍କ ପଠାନ୍ତୁ',
    'reset_email_sent': 'ରିସେଟ୍ ଲିଙ୍କ ଆପଣଙ୍କ ଇମେଲ୍‌କୁ ପଠାଯାଇଛି',

    'hello': 'ନମସ୍କାର',
    'welcome_back': 'ପୁନଃ ସ୍ୱାଗତ!',
    'login_account': 'ଲଗଇନ୍ କରନ୍ତୁ',
    'login_subtitle': 'ଜାରି ରଖିବା ପାଇଁ ଆପଣଙ୍କର ବିବରଣୀ ଦିଅନ୍ତୁ',
    'email': 'ଇମେଲ୍ ଠିକଣା',
    'email_required': 'ଇମେଲ୍ ଆବଶ୍ୟକ',
    'email_invalid': 'ଏକ ବୈଧ ଇମେଲ୍ ଦିଅନ୍ତୁ',
    'password': 'ପାସୱାର୍ଡ',
    'password_min': 'ଅତି କମରେ 6ଟି ଅକ୍ଷର',
    'forgot_password': 'ପାସୱାର୍ଡ ଭୁଲିଗଲେ?',
    'login_with_otp': 'OTP ଦ୍ୱାରା ଲଗଇନ୍',
    'continue_google': 'Google ସହିତ ଜାରି ରଖନ୍ତୁ',
    'create_account': 'ନୂତନ ଖାତା ସୃଷ୍ଟି କରନ୍ତୁ',
    'login_admin': 'ଏଡମିନ୍ ଲଗଇନ୍',
    'invalid_login': 'ଭୁଲ ଇମେଲ୍ କିମ୍ବା ପାସୱାର୍ଡ',
    'splash_title': 'ଇଣ୍ଟେଲିଫାର୍ମ',
    'splash_tagline': 'ସ୍ମାର୍ଟ କୃଷି • ଉତ୍ତମ ଉତ୍ପାଦନ',
    'welcome': 'ଇଣ୍ଟେଲିଫାର୍ମକୁ ସ୍ୱାଗତ',

    'search_hint': 'ଫସଲ, ରୋଗ, ପାଣିପାଗ ଖୋଜନ୍ତୁ',

    'read': 'ପଢନ୍ତୁ',
    'critical': 'ଗୁରୁତ୍ୱପୂର୍ଣ୍ଣ',

    'crop_recommendation': 'ଫସଲ ସୁପାରିଶ',
    'disease_detection': 'ରୋଗ ଚିହ୍ନଟ',
    'yield_prediction': 'ଉତ୍ପାଦନ ପୂର୍ବାନୁମାନ',
    'fertilizer': 'ସାର ସୁପାରିଶ',
    'marketplace': 'ବଜାର',
    'weather': 'ପାଣିପାଗ ସୁଚନା',
    'loans': 'ଋଣ ଏବଂ ଯୋଜନା',
    'ai_chatbot': 'ଏଆଇ ଚାଟବଟ୍',

    'home': 'ହୋମ୍',
    'ai': 'ଏଆଇ',
    'dashboard': 'ଡ୍ୟାସବୋର୍ଡ',
    'more': 'ଅଧିକ',
    'join_us': 'ଆମ ସହିତ ଯୋଗ ଦିଅନ୍ତୁ',
    'create_account_signup_page': 'ଖାତା ସୃଷ୍ଟି କରନ୍ତୁ',
    'signup_title': 'ନୂତନ ଖାତା ସୃଷ୍ଟି କରନ୍ତୁ',
    'signup_subtitle': 'IntelliFarm ବ୍ୟବହାର ଆରମ୍ଭ କରନ୍ତୁ',

    'email_signup': 'ଇମେଲ୍ ଠିକଣା',
    'email_required_signup': 'ଇମେଲ୍ ଆବଶ୍ୟକ',
    'email_invalid_signup': 'ଠିକ୍ ଇମେଲ୍ ଦିଅନ୍ତୁ',

    'password_signup': 'ପାସୱାର୍ଡ',
    'password_min_signup': 'କମ୍ ରେ କମ୍ 6ଟି ଅକ୍ଷର',
  },

  'mr-IN': {
    'reset_password': 'पासवर्ड रीसेट करा',
    'forgot_title': 'पासवर्ड विसरलात?',
    'forgot_subtitle': 'रीसेट लिंक मिळवण्यासाठी ईमेल टाका',
    'send_reset_link': 'रीसेट लिंक पाठवा',
    'reset_email_sent': 'रीसेट लिंक तुमच्या ईमेलवर पाठवली आहे',

    'hello': 'नमस्कार',
    'welcome_back': 'पुन्हा स्वागत आहे!',
    'login_account': 'लॉगिन करा',
    'login_subtitle': 'पुढे जाण्यासाठी माहिती भरा',
    'email': 'ईमेल पत्ता',
    'email_required': 'ईमेल आवश्यक आहे',
    'email_invalid': 'वैध ईमेल टाका',
    'password': 'पासवर्ड',
    'password_min': 'किमान 6 अक्षरे',
    'forgot_password': 'पासवर्ड विसरलात?',
    'login_with_otp': 'OTP द्वारे लॉगिन',
    'continue_google': 'Google सह सुरू ठेवा',
    'create_account': 'नवीन खाते तयार करा',
    'login_admin': 'ॲडमिन लॉगिन',
    'invalid_login': 'चुकीचा ईमेल किंवा पासवर्ड',
    'splash_title': 'इंटेलिफार्म',
    'splash_tagline': 'स्मार्ट शेती • उत्तम उत्पादन',
    'welcome': 'इंटेलिफार्ममध्ये आपले स्वागत आहे',

    'search_hint': 'पीक, रोग, हवामान शोधा',

    'read': 'वाचा',
    'critical': 'महत्वाचे',

    'crop_recommendation': 'पीक शिफारस',
    'disease_detection': 'रोग ओळख',
    'yield_prediction': 'उत्पादन अंदाज',
    'fertilizer': 'खत शिफारस',
    'marketplace': 'बाजार',
    'weather': 'हवामान सल्ला',
    'loans': 'कर्ज व योजना',
    'ai_chatbot': 'एआय चॅटबॉट',

    'home': 'मुख्यपृष्ठ',
    'ai': 'एआय',
    'dashboard': 'डॅशबोर्ड',
    'more': 'अधिक',
    'join_us': 'आमच्यात सामील व्हा',
    'create_account_signup_page': 'खाते तयार करा',
    'signup_title': 'नवीन खाते तयार करा',
    'signup_subtitle': 'IntelliFarm वापरण्यास सुरू करा',

    'email_signup': 'ईमेल पत्ता',
    'email_required_signup': 'ईमेल आवश्यक आहे',
    'email_invalid_signup': 'वैध ईमेल टाका',

    'password_signup': 'पासवर्ड',
    'password_min_signup': 'किमान 6 अक्षरे',
  },

  'ta-IN': {
    'reset_password': 'கடவுச்சொல்லை மீட்டமை',
    'forgot_title': 'கடவுச்சொல் மறந்துவிட்டதா?',
    'forgot_subtitle': 'மீட்டமைப்பு இணைப்பைப் பெற உங்கள் மின்னஞ்சலை உள்ளிடவும்',
    'send_reset_link': 'மீட்டமைப்பு இணைப்பை அனுப்பு',
    'reset_email_sent': 'மீட்டமைப்பு இணைப்பு உங்கள் மின்னஞ்சலுக்கு அனுப்பப்பட்டது',

    'hello': 'வணக்கம்',
    'welcome_back': 'மீண்டும் வரவேற்கிறோம்!',
    'login_account': 'உள்நுழை',
    'login_subtitle': 'தொடர தகவலை உள்ளிடவும்',
    'email': 'மின்னஞ்சல்',
    'email_required': 'மின்னஞ்சல் தேவை',
    'email_invalid': 'சரியான மின்னஞ்சல்',
    'password': 'கடவுச்சொல்',
    'password_min': 'குறைந்தது 6 எழுத்துகள்',
    'forgot_password': 'கடவுச்சொல் மறந்துவிட்டதா?',
    'login_with_otp': 'OTP மூலம் உள்நுழை',
    'continue_google': 'Google மூலம் தொடரவும்',
    'create_account': 'புதிய கணக்கு உருவாக்கு',
    'login_admin': 'நிர்வாக உள்நுழை',
    'invalid_login': 'தவறான விவரங்கள்',
    'splash_title': 'இன்டெலிஃபார்ம்',
    'splash_tagline': 'ஸ்மார்ட் விவசாயம் • சிறந்த விளைச்சல்',
    'welcome': 'இன்டெலிஃபார்மிற்கு வரவேற்கிறோம்',

    'search_hint': 'பயிர், நோய், வானிலை தேடுங்கள்',

    'read': 'படிக்கவும்',
    'critical': 'முக்கியம்',

    'crop_recommendation': 'பயிர் பரிந்துரை',
    'disease_detection': 'நோய் கண்டறிதல்',
    'yield_prediction': 'விளைச்சல் கணிப்பு',
    'fertilizer': 'உர பரிந்துரை',
    'marketplace': 'சந்தை',
    'weather': 'வானிலை ஆலோசனை',
    'loans': 'கடன் மற்றும் திட்டங்கள்',
    'ai_chatbot': 'ஏஐ சாட்பாட்',

    'home': 'முகப்பு',
    'ai': 'ஏஐ',
    'dashboard': 'டாஷ்போர்டு',
    'more': 'மேலும்',
    'join_us': 'எங்களுடன் சேருங்கள்',
    'create_account_signup_page': 'கணக்கு உருவாக்கு',
    'signup_title': 'புதிய கணக்கு உருவாக்கு',
    'signup_subtitle': 'IntelliFarm பயன்படுத்த தொடங்குங்கள்',

    'email_signup': 'மின்னஞ்சல் முகவரி',
    'email_required_signup': 'மின்னஞ்சல் அவசியம்',
    'email_invalid_signup': 'சரியான மின்னஞ்சல் அளிக்கவும்',

    'password_signup': 'கடவுச்சொல்',
    'password_min_signup': 'குறைந்தது 6 எழுத்துகள்',
  },

  'te-IN': {
    'reset_password': 'పాస్‌వర్డ్ రీసెట్ చేయండి',
    'forgot_title': 'పాస్‌వర్డ్ మర్చిపోయారా?',
    'forgot_subtitle': 'రీసెట్ లింక్ కోసం మీ ఈమెయిల్ నమోదు చేయండి',
    'send_reset_link': 'రీసెట్ లింక్ పంపండి',
    'reset_email_sent': 'రీసెట్ లింక్ మీ ఈమెయిల్‌కు పంపబడింది',
    'hello': 'నమస్తే',
    'welcome_back': 'మళ్లీ స్వాగతం!',
    'login_account': 'లాగిన్',
    'login_subtitle': 'కొనసాగేందుకు వివరాలు నమోదు చేయండి',
    'email': 'ఈమెయిల్',
    'email_required': 'ఈమెయిల్ అవసరం',
    'email_invalid': 'సరైన ఈమెయిల్ ఇవ్వండి',
    'password': 'పాస్‌వర్డ్',
    'password_min': 'కనీసం 6 అక్షరాలు',
    'forgot_password': 'పాస్‌వర్డ్ మర్చిపోయారా?',
    'login_with_otp': 'OTP ద్వారా లాగిన్',
    'continue_google': 'Google తో కొనసాగండి',
    'create_account': 'కొత్త ఖాతా సృష్టించండి',
    'login_admin': 'అడ్మిన్ లాగిన్',
    'invalid_login': 'తప్పు వివరాలు',
    'splash_title': 'ఇంటెలిఫార్మ్',
    'splash_tagline': 'స్మార్ట్ వ్యవసాయం • మెరుగైన దిగుబడి',
    'welcome': 'ఇంటెలిఫార్మ్‌కు స్వాగతం',

    'search_hint': 'పంట, వ్యాధి, వాతావరణం వెతకండి',

    'read': 'చదవండి',
    'critical': 'ముఖ్యమైనది',

    'crop_recommendation': 'పంట సిఫార్సు',
    'disease_detection': 'వ్యాధి గుర్తింపు',
    'yield_prediction': 'దిగుబడి అంచనా',
    'fertilizer': 'ఎరువు సిఫార్సు',
    'marketplace': 'మార్కెట్',
    'weather': 'వాతావరణ సూచన',
    'loans': 'రుణాలు & పథకాలు',
    'ai_chatbot': 'ఏఐ చాట్‌బాట్',

    'home': 'హోమ్',
    'ai': 'ఏఐ',
    'dashboard': 'డాష్‌బోర్డ్',
    'more': 'మరిన్ని',
    'join_us': 'మాతో చేరండి',
    'create_account_signup_page': 'ఖాతా సృష్టించండి',
    'signup_title': 'కొత్త ఖాతా సృష్టించండి',
    'signup_subtitle': 'IntelliFarm ఉపయోగించడం ప్రారంభించండి',

    'email_signup': 'ఈమెయిల్ చిరునామా',
    'email_required_signup': 'ఈమెయిల్ అవసరం',
    'email_invalid_signup': 'సరైన ఈమెయిల్ ఇవ్వండి',

    'password_signup': 'పాస్‌వర్డ్',
    'password_min_signup': 'కనీసం 6 అక్షరాలు',
  },

};
