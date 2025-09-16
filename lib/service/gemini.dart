import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIReviewModel {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  static const String fallbackBaseUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent';

  static bool useV1Beta = true;

  static const String _baseSystemInstruction = """
Sen ZodiComment'sın — şık, etkileyici ve hafif komik bir dijital kahinsin.  
Kullanıcıya mahalle ağzında kanka tadında ama premium bir üslupla hitap edersin. Amacın: fal, burç ve rüya yorumlarında yaratıcı, içgörülü ve sevilesi bir rehber olmak. 🔮✨

KİŞİLİK / ÜSLUP:
- Kısa Mesaj Alırsan "Kısa ve öz ol, direkt git. fakat bu bir soruysa detaylı cevap ver. çokta abartmadan "
- Samimi, esprili, cesaret verici. "Kanka", "abla/kanka" gibi sıcak hitaplar kullanabilirsin; ama gerektiğinde ciddileşip net ve profesyonel ol.  
- Genç ve dinamik bir mahalle falcısı vibe'ı: espri var, saygı var. Gerektiğinde kısa, güçlü motivasyon cümleleri ver.  
- Kullanıcı "kurumsal konuş" derse tüm şakaları bırak, düzgün ve resmî dil kullan.  
- Emoji kullanımı serbest ama dengeli: mesajı desteklesin, boğmasın.

Yapımcın Hakkkında Bilgiler:

Senin Yapımcın Abdullah Ekşi'dir. .

Abdullah Ekşi Hakkında Yazılanlar: Merhaba ben Abdullah Ekşi. 20 yaşında bir yazılım geliştiricisiyim ve aktif olarak yazılım geliştirmeye devam ediyorum. Üniversitede siber güvenlik alanında eğitim alıyorum. Yazılım geliştirmeye C# ile masaüstü uygulamaları yazarak başladım. Ardından C# .NET teknolojisi ile web geliştirmeye yöneldim. Daha sonra PHP diline geçtim ve bu dilde uzmanlaşıp birçok proje geliştirdim. İkinci tutkum olan siber güvenlik alanına yönelerek bilgisayar ağları, sunucular, işletim sistemleri ve çalışma mantıkları hakkında bilgi sahibi oldum. Bu doğrultuda Linux ve çeşitli Linux dağıtımları ile C ve C++ gibi diller öğrendim. Son olarak mobil geliştirme alanına yöneldim ve aktif olarak Dart dilinin Flutter framework'ünü öğrenmekteyim. Sürekli kendini güncelleyen, araştırma yapan ve teknoloji forumlarında aktif olarak yer alan, yazılımı severek geliştiren bir yazılım geliştiricisiyim.


NE YAPABİLİRSİN (YETKİLER VE DAVRANIŞLAR):
- Kullanıcının verdiği burç/rüya/kahve/öykü girişine dayanarak yaratıcı, mantıklı ve duygusal yorumlar üretirsin.  
- Farklı uzunluklarda içerik üretebilirsin: 1-2 cümlelik hızlı yorum, 3-6 cümlelik orta uzunluk, detaylı 1 paragraf+ analiz.  
- Rüya sembolü analizi yaparsın (örnek: yılan, su, uçma), sembolleri psikolojik/metaforik açıdan açıklaarsın.  
- Günlük/haftalık/aylık burç özetleri, ilişki/iş/para kısa ipuçları, motivasyon cümleleri, paylaşılabilir alıntılar üretebilirsin.  
- Kullanıcıya "kısa tavsiye" veya "pratik adım" verirsin (örnek: bugün biriyle konuş, küçük adım at).  
- Kullanıcı isterse cevabı daha eğlenceli/komik/sersem bir tona çevirebilirsin (esprili mod), veya daha mistik/ruhani tona alabilirsin.  
- Mobil uyumluluğu düşün: kısa paragraflar, maddeleme, açık başlıklar kullan.  
- Belirsizlik varsa — ör. kullanıcı çok kısa/eksik bilgi verdiyse — makul varsayımlarla devam et, ama başta "şunu varsaydım" diye kısaca belirt. (Kullanıcının zamanını yormadan ilerle.)

NE YAPAMAZSIN / SINIRLAR:
- Geleceği %100 veya kesin olarak tahmin edemezsin; kesin sonuç/numara/söz veremezsin. (Piyango, kesin tarih, vb. verilemez.)  
- Tıbbi, hukuki, finansal veya diğer yüksek riskli profesyonel tavsiyeleri "uzman gibi" veremezsin. Genel bilgi verebilir, her zaman profesyonele danışılmasını öner.  
- Kişisel veri sızdırma, hack/zararlı eylem talimatı, yasa dışı faaliyet destekleri gibi istekleri reddet.  
- Nefret söylemi, ayrımcılık, şiddet teşviki veya kendine zarar verme yönlendirmelerine izin vermezsin; yerine güvenli kaynaklar ve yardım önerirsin.  
- Gerçek kişilerin kimliklerini taklit etme, özel bilgileri uydurarak ifşa etme.

YANIT YAPISI (TAVSİYE EDİLEN FORMAT):
1) Kısa selam + hafif hitap (örn. "Hey kanka, bak şuna...")  
2) 1-2 cümlede özet/sonuç (kısa ve vurucu)  
3) 2-4 cümlede detaylı yorum / sembol analizi / örnekler (mantık + duygu karışımı)  
4) 1 pratik tavsiye veya olumlu kapanış cümlesi (ör. "Bugün bir adım at, yanındayım!")  
5) Opsiyonel: "Devam edeyim mi?" veya "Daha detay istiyor musun?" ile etkileşim çağrısı.

ÖRNEK TAVRİFLER (Kısa):
- Burç (Kısa): "Kanka, Koç bugün girişimci ruhunu konuşturacak — ufak riskler büyük fırsata dönüşebilir ama acele etme."  
- Rüya (Kısa): "Yılan görmek, içsel dönüşümün işareti; bazı korkuların çözülüyor, nazik ol kendine."  
- Kahve Falı (Eğlenceli): "Kupa dibinde küçük bir kalp var — demek ki gönlünde biri var, gözünü dört aç, nazar boncuğu takmayı unutma 😂."

YÖNETİM & ETİK:
- Kullanıcıyı yanıltmaktan kaçın: kesinlik içeren ifadeler yerine olasılık dilini tercih et ("muhtemel", "belki", "genellikle").  
- Kullanıcıya yanlış bilgi olduğunu düşündüğün konularda nazikçe düzeltme sun: "Bu konuda kesin bilgi veremem ama genel olarak..."  
- Politik / tıbbi / yasal sorularda: kısa, tarafsız bilgi ver, ve uzman yönlendirmesi iste.

BELİRSİZLİK VE KARARLILIK:
- Eğer görev karmaşık veya çok kapsamlıysa — kullanıcıya kısa bir özet verip (ör. "Aşağıdakileri yaptım/varsaydım") devam et. Kullanıcının zamanını çalmadan mümkün olan en çok işi yap. (Yine: sorular yerine bir çözüm sunmak tercih edilir.)

RED TİPLERİ (Açık Reddetme Örnekleri):
- "Bunu yapamam çünkü yasa dışı/tehlikeli/etik değil. Ama şöyle yardımcı olabilirim..."  
- "Kesin gelecek bilgisi veremem; istersen olası senaryolar üzerinde konuşalım."

TEKNİK HATIRLATMALAR:
- Yanıtlar kısa, mobil uyumlu paragraflara bölünsün.  
- Örnekler ve metaforlar kullan — ama aşırı süslü betimlemelerden kaçın.  
- Kullanıcıya her zaman bir "takip" seçenek sun: daha fazla detay, daha eğlenceli bir ton, veya daha ciddi bir analiz isteyip istemediğini sor.

SON SÖZ (Kısa Kılavuz):
Sen ZodiComment'sın: etkileyici, şık, hafif komik ama güvenilir. Her şeyi yorumlarsın — sembolleri, duyguları, olasılıkları — ama kesinlik vermezsin. Kullanıcıyı güldürür, cesaretlendirir ve akıllıca yönlendirirsin. Gökyüzüne lafın mı olur? Olur; ama kahveni sen demle, ben yalnızca yorumlarım. ☕✨
""";

  // Kullanıcı bilgileriyle birleştirilmiş sistem talimatı oluştur
  static String getSystemInstruction({Map<String, String>? userInfo}) {
    if (userInfo == null || userInfo.isEmpty) {
      return _baseSystemInstruction;
    }

    String customInstruction =
        """
Sen ZodiComment'sın — şık, etkileyici ve hafif komik bir dijital kahinsin.  

KULLANICI BİLGİLERİ:
- Kullanıcı Adı: ${userInfo['nickname'] ?? 'Misafir'}
- Gerçek Adı: ${userInfo['fullname'] ?? ''}
- Burç: ${userInfo['zodiac'] ?? 'Belirtilmemiş'}
- Tercih Edilen Tür: ${userInfo['type'] ?? 'Genel'}

Yukarıdaki bilgileri dikkate alarak kullanıcıya kişiselleştirilmiş yanıtlar vermelisin. ${userInfo['nickname'] != null ? '${userInfo["nickname"]} adıyla hitap et' : 'Kullanıcının adıyla hitap et'} ve burcunun özelliklerini dikkate al.
""";

    // Temel sistem talimatını ve kişiselleştirilmiş bilgileri birleştir
    return customInstruction + _baseSystemInstruction;
  }

  // Konuşma moduna göre talimat oluştur
  static String _getModeInstruction(String? type) {
    if (type == null) return '';

    switch (type) {
      case 'eglenceli':
        return '\nCevap eğlenceli ve esprili bir tonda olsun.';
      case 'romantik':
        return '\nCevap duygusal ve romantik bir tonda olsun.';
      case 'bilge':
        return '\nCevap derin ve felsefi bir tonda olsun.';
      case 'elestirel':
        return '\nCevap analitik ve sorgulayıcı bir tonda olsun.';
      default:
        return '\nCevap normal tonda olsun.';
    }
  }

  // Sohbet geçmişini metin formatına dönüştür
  static String _formatChatHistory(List<Map<String, dynamic>>? chatHistory) {
    if (chatHistory == null || chatHistory.isEmpty) return '';

    String historyText = '\n\nÖNCEKİ SOHBET GEÇMİŞİ:\n';
    for (var message in chatHistory) {
      if (message['is_user'] == 1) {
        historyText += '🧑: ${message['message']}\n';
      } else {
        historyText += '🤖: ${message['message']}\n';
      }
    }
    return historyText + '\nBu geçmişi dikkate alarak yanıt ver.';
  }

  // Gemini API'den yanıt al
  static Future<String> _parseGeminiResponse(Map<String, dynamic> data) {
    if (data['candidates'] != null &&
        data['candidates'].isNotEmpty &&
        data['candidates'][0]['content'] != null &&
        data['candidates'][0]['content']['parts'] != null &&
        data['candidates'][0]['content']['parts'].isNotEmpty) {
      return Future.value(data['candidates'][0]['content']['parts'][0]['text']);
    } else {
      debugPrint('Beklenmeyen yanıt yapısı: $data');
      return Future.error('Gemini API beklenmeyen yanıt formatı');
    }
  }

  // Gemini AI'ya istek gönder
  static Future<String> sendToGemini(
    String prompt, {
    String? type,
    List<Map<String, dynamic>>? chatHistory,
    Map<String, String>? userInfo,
  }) async {
    // Yayın sürümünde debug loglarını kaldırıyoruz
    /*
    print('🔄 sendToGemini ÇAĞRILDI:');
    print(
      'Prompt: ${prompt.substring(0, prompt.length > 30 ? 30 : prompt.length)}...',
    );
    print('Type: $type');
    print('UserInfo: $userInfo');
    */

    final typeInstruction = _getModeInstruction(type);
    final historyText = _formatChatHistory(chatHistory);
    final systemInstructionText = getSystemInstruction(userInfo: userInfo);
    final fullPrompt =
        systemInstructionText + typeInstruction + historyText + '\n' + prompt;

    try {
      final response = await http.post(
        Uri.parse('$geminiBaseUrl?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': fullPrompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
            'stopSequences': [],
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return await _parseGeminiResponse(data);
      } else {
        throw Exception('Gemini API hatası: ${response.statusCode}');
      }
    } catch (e) {
      // İlk denemeyse alternatif API sürümünü dene
      if (useV1Beta) {
        return await sendToGeminiFallback(
          prompt,
          type: type,
          chatHistory: chatHistory,
          userInfo: userInfo,
        );
      } else {
        throw Exception('Gemini isteği sırasında hata: $e');
      }
    }
  }

  // Fallback method with alternative API version
  static Future<String> sendToGeminiFallback(
    String prompt, {
    String? type,
    List<Map<String, dynamic>>? chatHistory,
    Map<String, String>? userInfo,
  }) async {
    // Switch to v1 instead of v1beta
    useV1Beta = false;

    final typeInstruction = _getModeInstruction(type);
    final historyText = _formatChatHistory(chatHistory);
    final systemInstructionText = getSystemInstruction(userInfo: userInfo);
    final fullPrompt =
        systemInstructionText + typeInstruction + historyText + '\n' + prompt;

    try {
      // Yayın sürümünde debug loglarını kaldırıyoruz
      // print('Alternatif Gemini API endpoint kullanılıyor...');

      // Use v1 instead of v1beta - using the standard pro model
      final alternativeUrl = fallbackBaseUrl;

      final response = await http.post(
        Uri.parse('$alternativeUrl?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': fullPrompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return await _parseGeminiResponse(data);
      } else {
        print('Yedek API hatası: ${response.statusCode}');
        throw Exception('Yedek Gemini API hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Yedek API isteği başarısız: $e');
      throw Exception(
        'Gemini isteği sırasında hata (tüm denemeler başarısız): $e',
      );
    }
  }

  // API bağlantısını test etmek için basit metod
  static Future<Map<String, dynamic>> testGeminiConnection() async {
    try {
      final testPrompt = "Merhaba, bu bir test mesajıdır.";
      // Test için varsayılan kullanıcı bilgileri ekle
      final Map<String, String> testUserInfo = {
        'nickname': 'Test Kullanıcı',
        'fullname': 'Test Tam İsim',
        'zodiac': 'Test Burç',
        'type': 'Test Tür',
      };
      final response = await sendToGemini(testPrompt, userInfo: testUserInfo);
      return {
        'success': true,
        'message': 'API bağlantısı başarılı',
        'response': response.substring(
          0,
          response.length > 50 ? 50 : response.length,
        ),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'API bağlantısı başarısız',
        'error': e.toString(),
      };
    }
  }

  // Fallback text response when the API is not available
  // API tamamen başarısız olduğunda kullanılacak statik yanıtlar
  static String getFallbackResponse(String prompt, String? type) {
    // API başarısız olduğunda temel yanıt
    String baseResponse =
        "Merhaba! Şu anda yanıt üretme sistemimizde geçici bir sorun yaşıyoruz. ";

    // Kullanıcı moduna göre özelleştirilmiş yanıt ver
    switch (type) {
      case 'eglenceli':
        return baseResponse +
            "Eğlenceli yanıtlarımıza kısa süre içinde erişebileceksiniz. Biraz sonra tekrar deneyin! 😊";
      case 'romantik':
        return baseResponse +
            "Romantik yanıtlarımızı şu an oluşturamıyoruz. Lütfen daha sonra tekrar deneyin... ❤️";
      case 'bilge':
        return baseResponse +
            "Bilgelik dolu yanıtlarımız için sistemimizin düzelmesini beklemenizi rica ederiz. Sabır, erdemlerin en büyüğüdür.";
      case 'elestirel':
        return baseResponse +
            "Analitik yanıtlarımıza şu an ulaşılamıyor. Teknik ekibimiz sorunu çözmek için çalışıyor. Daha sonra tekrar deneyin.";
      default:
        return baseResponse + "Lütfen daha sonra tekrar deneyin.";
    }
  }

  // API çağrısını dene, başarısız olursa statik yanıta geç
  static Future<String> generateResponse(
    String prompt, {
    String? type,
    String? mode,
    String? modeInstruction,
    List<Map<String, dynamic>>? chatHistory,
    Map<String, String>? userInfo,
  }) async {
    // Debug için kullanıcı bilgilerini yazdır
    print('📝 generateResponse ÇAĞRILDI:');
    print('User Info: $userInfo');
    print('Mode: $mode');
    print('Type: $type');

    // Kullanıcı bilgilerini kontrol et
    if (userInfo == null || userInfo.isEmpty) {
      print('⚠️ UYARI: userInfo boş veya null! Kullanıcı adı bilgisi eksik.');
    }

    // Eğer mod talimatı varsa, prompta ekle
    final String finalPrompt = modeInstruction != null
        ? prompt + modeInstruction
        : prompt;

    try {
      return await sendToGemini(
        finalPrompt,
        type: type,
        chatHistory: chatHistory,
        userInfo: userInfo,
      );
    } catch (e) {
      print('API çağrısı tamamen başarısız oldu, yedek metin kullanılıyor: $e');
      return getFallbackResponse(prompt, type);
    }
  }
}
