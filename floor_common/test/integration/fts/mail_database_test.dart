import 'package:test/test.dart';

import 'mail.dart';
import 'mail_dao.dart';
import 'mail_database.dart';

void main() {
  final Map<int, String> mailMap = {
    1: 'M1 is here. Our first chip designed specifically for Mac, it delivers incredible performance, custom technologies, and revolutionary power efficiency. And it was designed from the very start to work with the most advanced desktop operating system in the world, macOS Big Sur. With a giant leap in performance per watt, every Mac with M1 is transformed into a completely different class of product. This isn’t an upgrade. It’s a breakthrough.',
    2: 'Until now, a Mac needed multiple chips to deliver all of its features — including the processor, I/O, security, and memory. With M1, these technologies are combined into a single system on a chip (SoC), delivering a new level of integration for more simplicity, more efficiency, and amazing performance. And with incredibly small transistors measured at an atomic scale, M1 is remarkably complex — packing the largest number of transistors we’ve ever put into a single chip. It’s also the first personal computer chip built using industry‑leading 5‑nanometer process technology.',
    3: 'M1 also features our unified memory architecture, or UMA. M1 unifies its high‑bandwidth, low‑latency memory into a single pool within a custom package. As a result, all of the technologies in the SoC can access the same data without copying it between multiple pools of memory. This dramatically improves performance and power efficiency. Video apps are snappier. Games are richer and more detailed. Image processing is lightning fast. And your entire system is more responsive.',
    4: 'The 8‑core CPU in M1 is by far the highest‑performance CPU we’ve ever built. Designed to crush tasks using the least amount of power, M1 features two types of cores: high performance and high efficiency. So from editing family photos to exporting iMovie videos for the web to managing huge RAW libraries in Lightroom to checking your email, M1 blazes right through it all — without blazing through battery life.',
    5: 'M1 features four performance cores, each designed to run a single task as efficiently as possible while maximizing performance. Our high‑performance core is the world’s fastest CPU core when it comes to low‑power silicon.3 And because M1 has four of them, multithreaded workloads take a huge leap in performance as well.',
  };

  group('Fts Database Test', () {
    late MailDatabase mailDatabase;
    late MailDao mailDao;

    setUp(() async {
      mailDatabase = await $FloorMailDatabase.inMemoryDatabaseBuilder().build();
      mailDao = mailDatabase.mailDao;
    });

    tearDown(() async {
      await mailDatabase.close();
    });

    test('dao query', () async {
      mailMap.forEach((key, value) async {
        await mailDao.insertMail(Mail(key, value));
      });

      var mailList = await mailDao.findAllMails();

      expect(mailList.length, equals(5));

      final mail = (await mailDao.findMailById(1))!;

      expect(mailMap[1], mail.text);

      mailList = await mailDao.findMailByKey('designed');

      expect(mailList.length, equals(3));
    });
  });
}
