import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/build_context_extensions.dart';

const List<Map<String, String>> supportedLanguages = [
  {'code': 'en', 'name': 'English'},
  {'code': 'es', 'name': 'Español'},
  {'code': 'fr', 'name': 'Français'},
  {'code': 'de', 'name': 'Deutsch'},
  {'code': 'zh', 'name': '中文'},
  {'code': 'ja', 'name': '日本語'},
  {'code': 'ko', 'name': '한국어'},
  {'code': 'ru', 'name': 'Русский'},
  {'code': 'ar', 'name': 'العربية'},
  {'code': 'pt', 'name': 'Português'},
  {'code': 'it', 'name': 'Italiano'},
  {'code': 'nl', 'name': 'Nederlands'},
  {'code': 'sv', 'name': 'Svenska'},
  {'code': 'no', 'name': 'Norsk'},
  {'code': 'da', 'name': 'Dansk'},
  {'code': 'fi', 'name': 'Suomi'},
  {'code': 'pl', 'name': 'Polski'},
  {'code': 'tr', 'name': 'Türkçe'},
  {'code': 'th', 'name': 'ไทย'},
  {'code': 'vi', 'name': 'Tiếng Việt'},
  {'code': 'id', 'name': 'Bahasa Indonesia'},
  {'code': 'ms', 'name': 'Bahasa Melayu'},
  {'code': 'hi', 'name': 'हिन्दी'},
  {'code': 'bn', 'name': 'বাংলা'},
  {'code': 'pa', 'name': 'ਪੰਜਾਬੀ'},
  {'code': 'ta', 'name': 'தமிழ்'},
  {'code': 'te', 'name': 'తెలుగు'},
  {'code': 'mr', 'name': 'मराठी'},
  {'code': 'gu', 'name': 'ગુજરાતી'},
  {'code': 'kn', 'name': 'ಕನ್ನಡ'},
  {'code': 'ml', 'name': 'മലയാളം'},
  {'code': 'or', 'name': 'ଓଡ଼ିଆ'},
  {'code': 'as', 'name': 'অসমীয়া'},
  {'code': 'ur', 'name': 'اردو'},
  {'code': 'fa', 'name': 'فارسی'},
  {'code': 'he', 'name': 'עברית'},
  {'code': 'el', 'name': 'Ελληνικά'},
  {'code': 'hu', 'name': 'Magyar'},
  {'code': 'cs', 'name': 'Čeština'},
  {'code': 'sk', 'name': 'Slovenčina'},
  {'code': 'uk', 'name': 'Українська'},
  {'code': 'bg', 'name': 'Български'},
  {'code': 'sr', 'name': 'Српски'},
  {'code': 'hr', 'name': 'Hrvatski'},
  {'code': 'sl', 'name': 'Slovenščina'},
  {'code': 'et', 'name': 'Eesti'},
  {'code': 'lv', 'name': 'Latviešu'},
  {'code': 'lt', 'name': 'Lietuvių'},
  {'code': 'is', 'name': 'Íslenska'},
  {'code': 'ga', 'name': 'Gaeilge'},
  {'code': 'gd', 'name': 'Gàidhlig'}, // Scottish Gaelic
  {'code': 'cy', 'name': 'Cymraeg'}, // Welsh
  {'code': 'eu', 'name': 'Euskara'}, // Basque
  {'code': 'ca', 'name': 'Català'}, // Catalan
  {'code': 'gl', 'name': 'Galego'}, // Galician
  {'code': 'af', 'name': 'Afrikaans'},
  {'code': 'sw', 'name': 'Kiswahili'},
  {'code': 'am', 'name': 'አማርኛ'}, // Amharic
  {'code': 'ne', 'name': 'नेपाली'}, // Nepali
  {'code': 'si', 'name': 'සිංහල'}, // Sinhala
  {'code': 'km', 'name': 'ខ្មែរ'}, // Khmer
  {'code': 'lo', 'name': 'ລາວ'}, // Lao
  {'code': 'my', 'name': 'မြန်မာ'}, // Burmese
  {'code': 'ka', 'name': 'ქართული'}, // Georgian
  {'code': 'az', 'name': 'Azərbaycan dili'}, // Azerbaijani
  {'code': 'uz', 'name': 'Oʻzbek'}, // Uzbek
  {'code': 'kk', 'name': 'Қазақ тілі'}, // Kazakh
  {'code': 'ky', 'name': 'Кыргызча'}, // Kyrgyz
  {'code': 'tk', 'name': 'Türkmençe'}, // Turkmen
  {'code': 'mn', 'name': 'Монгол хэл'}, // Mongolian
  {'code': 'bo', 'name': 'བོད་སྐད་'}, // Tibetan
  {'code': 'ug', 'name': 'ئۇيغۇرچە‎'}, // Uyghur
  {'code': 'dz', 'name': 'རྫོང་ཁ'}, // Dzongkha
  {'code': 'sg', 'name': 'Sängö'}, // Sango
  {'code': 'ln', 'name': 'Lingála'}, // Lingala
  {'code': 'wo', 'name': 'Wolof'},
  {'code': 'yo', 'name': 'Yorùbá'},
  {'code': 'ig', 'name': 'Asụsụ Igbo'}, // Igbo
  {'code': 'ha', 'name': 'Hausa'},
  {'code': 'ff', 'name': 'Fulfulde'}, // Fulah
  {'code': 'so', 'name': 'Soomaali'}, // Somali
  {'code': 'om', 'name': 'Oromoo'}, // Oromo
  {'code': 'ti', 'name': 'ትግርኛ'}, // Tigrinya
  {'code': 'ak', 'name': 'Akan'},
  {'code': 'zu', 'name': 'isiZulu'}, // Zulu
  {'code': 'xh', 'name': 'isiXhosa'}, // Xhosa
  {'code': 'st', 'name': 'Sesotho'}, // Southern Sotho
  {'code': 'tn', 'name': 'Setswana'}, // Tswana
  {'code': 've', 'name': 'Tshivenda'}, // Venda
  {'code': 'ts', 'name': 'Xitsonga'}, // Tsonga
  {'code': 'ss', 'name': 'siSwati'}, // Swati
  {'code': 'rw', 'name': 'Kinyarwanda'},
  {'code': 'rn', 'name': 'Kirundi'},
  {'code': 'kg', 'name': 'Kikongo'}, // Kongo
  {'code': 'mg', 'name': 'Malagasy'},
  {'code': 'hy', 'name': 'Հայերեն'}, // Armenian
  {'code': 'tg', 'name': 'Тоҷикӣ'}, // Tajik
  {'code': 'sd', 'name': 'سنڌي‎'}, // Sindhi
  {'code': 'fy', 'name': 'Frysk'}, // Frisian
  {'code': 'mt', 'name': 'Malti'}, // Maltese
  {'code': 'fo', 'name': 'Føroyskt'}, // Faroese
  {'code': 'yi', 'name': 'ייִדיש'}, // Yiddish
  {'code': 'eo', 'name': 'Esperanto'}, // Esperanto
  {'code': 'ia', 'name': 'Interlingua'}, // Interlingua
  {'code': 'ie', 'name': 'Interlingue'}, // Interlingue
  {'code': 'oj', 'name': 'ᐊᓂᔑᓈᐯᒧᐎᓐ'}, // Ojibwe
  {'code': 'iu', 'name': 'ᐃᓄᒃᑎᑐᑦ'}, // Inuktitut
  {'code': 'ik', 'name': 'Iñupiaq'}, // Iñupiaq
  {'code': 'ch', 'name': 'Chamoru'}, // Chamorro
  {'code': 'to', 'name': 'Faka Tonga'}, // Tongan
  {'code': 'sm', 'name': 'Gagana Sāmoa'}, // Samoan
  {'code': 'fj', 'name': 'Vosa Vakaviti'}, // Fijian
  {'code': 'mh', 'name': 'Kajin M̧ajeļ'}, // Marshallese
  {'code': 'kl', 'name': 'Kalaallisut'}, // Kalaallisut
  {'code': 'gn', 'name': 'Avañeʼẽ'}, // Guarani
  {'code': 'ay', 'name': 'Aymar aru'}, // Aymara
  {'code': 'qu', 'name': 'Runa Simi'}, // Quechua
  {'code': 'nv', 'name': 'Diné bizaad'}, // Navajo
  {'code': 'tl', 'name': 'Tagalog'}, // Tagalog
  {'code': 'sc', 'name': 'Sardu'}, // Sardinian
  {'code': 'co', 'name': 'Corsu'}, // Corsican
  {'code': 'li', 'name': 'Limburgs'}, // Limburgish
  {'code': 'lu', 'name': 'Tshiluba'}, // Luba-Katanga
  {'code': 'gv', 'name': 'Gaelg'}, // Manx
  {'code': 'nd', 'name': 'isiNdebele'}, // Northern Ndebele
  {'code': 'nr', 'name': 'isiNdebele'}, // Southern Ndebele
  {'code': 'rm', 'name': 'Rumantsch Grischun'}, // Romansh
  {'code': 'se', 'name': 'Davvisámegiella'}, // Northern Sami
  {'code': 'be', 'name': 'Беларуская'}, // Belarusian
  {'code': 'br', 'name': 'Brezhoneg'}, // Breton
  {'code': 'bs', 'name': 'Bosanski'}, // Bosnian
  {'code': 'ce', 'name': 'Нохчийн'}, // Chechen
  {'code': 'cr', 'name': ' Cree'}, // Cree
  {'code': 'cu', 'name': ' Slavonic'}, // Church Slavic
  {'code': 'cv', 'name': 'Чӑвашла'}, // Chuvash
  {'code': 'dv', 'name': 'ދިވެހި'}, // Divehi
  {'code': 'ee', 'name': 'Èʋegbe'}, // Ewe
  {'code': 'ho', 'name': 'Hiri Motu'}, // Hiri Motu
  {'code': 'ht', 'name': 'Kreyòl ayisyen'}, // Haitian Creole
  {'code': 'hz', 'name': 'Otjiherero'}, // Herero
  {'code': 'ii', 'name': 'ꆇꉙ'}, // Sichuan Yi
  {'code': 'io', 'name': 'Ido'}, // Ido
  {'code': 'jv', 'name': 'Basa Jawa'}, // Javanese
  {'code': 'ki', 'name': 'Gikuyu'}, // Kikuyu
  {'code': 'kj', 'name': 'Kuanyama'}, // Kwanyama
  {'code': 'kr', 'name': 'Kanuri'}, // Kanuri
  {'code': 'ks', 'name': 'کٲشُر'}, // Kashmiri
  {'code': 'ku', 'name': 'Kurdî'}, // Kurdish
  {'code': 'kv', 'name': 'Коми'}, // Komi
  {'code': 'kw', 'name': 'Kernowek'}, // Cornish
  {'code': 'la', 'name': 'Latina'}, // Latin
  {'code': 'lb', 'name': 'Lëtzebuergesch'}, // Luxembourgish
  {'code': 'lg', 'name': 'Luganda'}, // Ganda
  {'code': 'mi', 'name': 'Māori'}, // Maori
  {'code': 'mk', 'name': 'Македонски'}, // Macedonian
  {'code': 'na', 'name': 'Dorerin Naoero'}, // Nauru
  {'code': 'nb', 'name': 'Norsk bokmål'}, // Norwegian Bokmål
  {'code': 'ng', 'name': 'Ndonga'}, // Ndonga
  {'code': 'nn', 'name': 'Norsk nynorsk'}, // Norwegian Nynorsk
  {'code': 'ny', 'name': 'Chichewa'}, // Chichewa
  {'code': 'oc', 'name': 'Occitan'}, // Occitan
  {'code': 'pi', 'name': 'पालि'}, // Pali
  {'code': 'ps', 'name': 'پښتو'}, // Pashto
  {'code': 'ro', 'name': 'Română'}, // Romanian
  {'code': 'sa', 'name': 'संस्कृतम्'}, // Sanskrit
  {'code': 'sn', 'name': 'chiShona'}, // Shona
  {'code': 'so', 'name': 'Soomaali'}, // Somali
  {'code': 'sq', 'name': 'Shqip'}, // Albanian
  {'code': 'su', 'name': 'Basa Sunda'}, // Sundanese
  {'code': 'tt', 'name': 'Татар теле'}, // Tatar
  {'code': 'tw', 'name': 'Twi'}, // Twi
  {'code': 'ty', 'name': 'Reo Tahiti'}, // Tahitian
  {'code': 'vo', 'name': 'Volapük'}, // Volapük
  {'code': 'wa', 'name': 'Walon'}, // Walloon
  {'code': 'za', 'name': 'Saw cuengh'}, // Zhuang
];

class LanguageAutocompletePicker extends StatelessWidget {
  /// Callback function when a language is selected.
  final ValueChanged<Map<String, String>> onLanguageSelected;

  /// Optional initial text for the search field.
  final String? initialText;

  final String? label;

  const LanguageAutocompletePicker({
    super.key,
    required this.onLanguageSelected,
    this.initialText,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    // Options are the Map<String, String> objects from the list
    return Autocomplete<Map<String, String>>(
      // Provides the list of options based on the current text field value.
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Map<String, String>>.empty();
        }
        return supportedLanguages.where((Map<String, String> language) {
          // Filter based on whether the language name (endonym) contains the input text (case-insensitive)
          return language['name']!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()) ||
              language['code']!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (Map<String, String> option) => option['name']!,

      // Called when an option is selected from the list.
      onSelected: (Map<String, String> selectedLanguage) {
        debugPrint(
            'Selected language: ${selectedLanguage['name']} (${selectedLanguage['code']})');
        onLanguageSelected(selectedLanguage);
      },

      // Builds the text field where the user types.
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        // Set initial text if provided
        if (initialText != null && textEditingController.text.isEmpty) {
          textEditingController.text = initialText!;
        }

        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
              label: Text(context.l10n.languageHint),
              border: OutlineInputBorder(),
              helperText: label),
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },

      // Builds the widget that displays the options.
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<Map<String, String>> onSelected,
          Iterable<Map<String, String>> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200.0, // Set a fixed height for the dropdown
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, String> language = options.elementAt(index);
                  return ListTile(
                    title: Text(language['name']!),
                    // You could show the code as a subtitle if desired
                    // subtitle: Text(language['code']!),
                    onTap: () {
                      onSelected(language);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}