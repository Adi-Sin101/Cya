// Curated synthetic seed, not representative quality acceptance. No user data.
import 'dart:convert';
import 'dart:math';

import 'package:cya/native/embedding_port.dart';
import 'package:flutter/material.dart';

const _seed = [
  (
    topic: 'book',
    documents: [
      'I left the novel on my desk to read this evening.',
      'আজ সন্ধ্যায় পড়ব বলে উপন্যাসটা টেবিলে রেখেছি।',
      'Ami shondhay porar jonno uponnash ta table e rekhechi.',
    ],
    queries: [
      'My plan for spending time with a story',
      'পড়ার জন্য রাখা উপন্যাসটার কথা মনে করাও',
      'notun golper boi ta porar plan ki chhilo',
    ],
  ),
  (
    topic: 'tea',
    documents: [
      'I want fresh ginger in my morning tea.',
      'সকালের চায়ে তাজা আদা মেশাতে চাই।',
      'Shokaler cha te fresh ada dibo.',
    ],
    queries: [
      'The warm drink I wanted to make after waking up',
      'ঘুম থেকে উঠে কোন গরম পানীয় বানাতে চেয়েছিলাম',
      'ghum theke uthe gorom kichhu bananor idea',
    ],
  ),
  (
    topic: 'meeting',
    documents: [
      'Our team reviews project progress together on Wednesday at three.',
      'বুধবার তিনটায় দলের সঙ্গে প্রকল্পের অগ্রগতি নিয়ে বসব।',
      'Budhbar tintae team er kaajer update niye boshbo.',
    ],
    queries: [
      'When is the group progress check-in?',
      'দলের কাজের আলোচনা কখন হবে',
      'team er progress check korar shomoy',
    ],
  ),
  (
    topic: 'mother',
    documents: [
      'Call my mother tonight and ask how her day went.',
      'রাতে মাকে ফোন করে তাঁর দিনের কথা শুনব।',
      'Raate ma ke phone diye diner kotha shunbo.',
    ],
    queries: [
      'The family conversation I wanted to have later',
      'মায়ের খোঁজ নেওয়ার কথা কোথায় লিখেছি',
      'pore ma er shathe kotha bolar reminder',
    ],
  ),
  (
    topic: 'grocery',
    documents: [
      'The shopping list needs rice, eggs and green vegetables.',
      'বাজারের তালিকায় চাল, ডিম আর সবুজ সবজি লাগবে।',
      'Bazarer list e chal dim ar shobuj shobji lagbe.',
    ],
    queries: [
      'Food supplies I planned to buy',
      'কী কী খাবার কিনতে হবে',
      'khabarer shopping list ta dekhao',
    ],
  ),
  (
    topic: 'bicycle',
    documents: [
      'The bicycle brakes feel loose; bring it to the repair shop.',
      'সাইকেলের ব্রেক ঢিলে লাগছে, মিস্ত্রির কাছে নিতে হবে।',
      'Cycle er brake dhila, repair shop e nite hobe.',
    ],
    queries: [
      'The problem with stopping my bike safely',
      'সাইকেল থামানোর সমস্যাটা কী ছিল',
      'cycle thamanor problem er note',
    ],
  ),
  (
    topic: 'loginbug',
    documents: [
      'The login screen crashes when the saved profile is missing; check null handling.',
      'সেভ করা প্রোফাইল না থাকলে লগইন স্ক্রিন ক্র্যাশ করে; নাল হ্যান্ডলিং দেখব।',
      'Saved profile na thakle login screen crash kore, null handling check korbo.',
    ],
    queries: [
      'Where is the clue about the sign-in failure?',
      'সাইন ইন করতে গিয়ে অ্যাপ বন্ধ হওয়ার কারণ',
      'sign in korte gele app bondho hoy keno',
    ],
  ),
  (
    topic: 'garden',
    documents: [
      'Water the balcony plants when the soil feels dry in the afternoon.',
      'বিকেলে মাটি শুকনো লাগলে বারান্দার গাছে পানি দেব।',
      'Bikele mati shukna hole balcony r gachhe pani dibo.',
    ],
    queries: [
      'How I planned to care for the plants',
      'গাছের যত্নের জন্য কী করব',
      'gachhgulor jotno neyar plan',
    ],
  ),
  (
    topic: 'rent',
    documents: [
      'Keep the rent payment receipt inside the housing documents folder.',
      'বাড়িভাড়ার রসিদ বাসার কাগজপত্রের ফোল্ডারে রাখব।',
      'Basha bharar receipt housing documents folder e rakhbo.',
    ],
    queries: [
      'Where I put proof of paying for my home',
      'বাসার টাকা দেওয়ার প্রমাণ কোথায় রাখব',
      'basha bharar taka deyar proof kothay',
    ],
  ),
  (
    topic: 'train',
    documents: [
      'I reserved a train ticket for next Friday; keep the booking code with the journey plan.',
      'আগামী শুক্রবারের ট্রেনের টিকিট করেছি; বুকিং কোড যাত্রার পরিকল্পনার সঙ্গে রাখব।',
      'Agami shukrobarer train ticket book korsi, booking code trip plan er shathe rakhbo.',
    ],
    queries: [
      'The reservation for my upcoming rail journey',
      'সামনের রেলভ্রমণের বুকিং কোথায়',
      'shamner rail journey r reservation er kotha',
    ],
  ),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final output = ValueNotifier(
    'Running synthetic multilingual seed benchmark…',
  );
  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ValueListenableBuilder(
              valueListenable: output,
              builder: (context, value, _) => SelectableText(value),
            ),
          ),
        ),
      ),
    ),
  );
  const runtime = EmbeddingPort();
  try {
    if (!await runtime.installed()) {
      throw StateError('Verified local model required.');
    }
    final documents = [
      for (final row in _seed)
        for (var language = 0; language < 3; language++)
          (topic: row.topic, language: language, text: row.documents[language]),
    ];
    final reports = <String, Object?>{};
    for (final variant in ['official-card', 'runtime-guide']) {
      final corpus = <List<double>>[];
      for (final document in documents) {
        final prefix = variant == 'official-card'
            ? 'title: none | text: '
            : 'task: search result | text: ';
        corpus.add(await runtime.text('$prefix${document.text}'));
      }
      final byLanguage = <String, Object?>{};
      for (var language = 0; language < 3; language++) {
        var reciprocal = 0.0, recall = 0.0, hit = 0;
        final latency = <int>[];
        for (final query in _seed) {
          final prefix = variant == 'official-card'
              ? 'task: search result | query: '
              : 'task: search query | text: ';
          final clock = Stopwatch()..start();
          final vector = await runtime.text(
            '$prefix${query.queries[language]}',
          );
          clock.stop();
          latency.add(clock.elapsedMilliseconds);
          final ranks = [
            for (var i = 0; i < corpus.length; i++)
              (index: i, score: _dot(vector, corpus[i])),
          ]..sort((a, b) => b.score.compareTo(a.score));
          final first = ranks.indexWhere(
            (r) => documents[r.index].topic == query.topic,
          );
          if (first < 10) reciprocal += 1 / (first + 1);
          if (first == 0) hit++;
          recall +=
              ranks
                  .take(5)
                  .where((r) => documents[r.index].topic == query.topic)
                  .length /
              3;
        }
        latency.sort();
        byLanguage[['English', 'Bangla', 'Banglish'][language]] = {
          'queries': _seed.length,
          'hitAt1': hit / _seed.length,
          'mrrAt10': reciprocal / _seed.length,
          'recallAt5': recall / _seed.length,
          'warmP50Ms': latency[(latency.length * .5).floor()],
          'warmP95Ms':
              latency[min(
                latency.length - 1,
                (latency.length * .95).ceil() - 1,
              )],
        };
      }
      reports[variant] = byLanguage;
      debugPrint(
        'CYA_SEMANTIC_SEED_VARIANT=${jsonEncode({variant: byLanguage})}',
      );
    }
    final report = {
      'corpus': 'synthetic-cya-seed-20261015-v1',
      'documents': documents.length,
      'topics': _seed.length,
      'relevantPerQuery': 3,
      'queriesPerVariant': 30,
      'variants': reports,
      'limits':
          'small authored translations and romanizations; not representative user/audio/device acceptance',
    };
    output.value = jsonEncode(report);
    debugPrint('CYA_SEMANTIC_SEED=${jsonEncode(report)}');
  } on Object catch (error) {
    output.value = 'Seed benchmark failed: $error';
    debugPrint(output.value);
  } finally {
    await runtime.unload();
  }
}

double _dot(List<double> a, List<double> b) =>
    List.generate(a.length, (i) => a[i] * b[i]).fold(0, (sum, v) => sum + v);
