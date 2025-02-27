// Copyright 2021 Richard Easterling
// SPDX-License-Identifier: Apache-2.0

import 'package:cardano_wallet_sdk/cardano_wallet_sdk.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  Logger.root.level = Level.WARNING; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final logger = Logger('AdaFormatterTest');
  group('ADAFormattter - ', () {
    test('currency', () {
      final formatter = AdaFormattter.currency();
      logger.info(formatter.format(BigInt.from(120)));
      logger.info(formatter.format(BigInt.from(120000)));
      logger.info(formatter.format(BigInt.from(120000000)));
      logger.info(formatter.format(BigInt.from(120000000000)));
      logger.info(formatter.format(BigInt.from(120000000000000)));
      logger.info(formatter.format(BigInt.from(120000000000000000)));
      logger.info(formatter.format(BigInt.from(9000000000000000000)));
      expect(formatter.format(BigInt.from(120)), equals('₳0.000120'));
      expect(formatter.format(BigInt.from(120000)), equals('₳0.120000'));
      expect(formatter.format(BigInt.from(120000000)), equals('₳120.000000'));
      expect(formatter.format(BigInt.from(120000000000)),
          equals('₳120,000.000000'));
      expect(formatter.format(BigInt.from(120000000000000)),
          equals('₳120,000,000.000000'));
      expect(formatter.format(BigInt.from(120000000000000000)),
          equals('₳120,000,000,000.000000'));
      expect(formatter.format(BigInt.from(9000000000000000000)),
          equals('₳9,000,000,000,000.000000'));
    });
    test('compactCurrency', () {
      final formatter = AdaFormattter.compactCurrency();
      logger.info(formatter.format(BigInt.from(120)));
      logger.info(formatter.format(BigInt.from(120000)));
      logger.info(formatter.format(BigInt.from(120000000)));
      logger.info(formatter.format(BigInt.from(120000000000)));
      logger.info(formatter.format(BigInt.from(120000000000000)));
      logger.info(formatter.format(BigInt.from(120000000000000000)));
      logger.info(formatter.format(BigInt.from(9000000000000000000)));
      expect(formatter.format(BigInt.from(120)), equals('₳0.000120'));
      expect(formatter.format(BigInt.from(120000)), equals('₳0.120000'));
      expect(formatter.format(BigInt.from(120000000)), equals('₳120'));
      expect(formatter.format(BigInt.from(120000000000)), equals('₳120K'));
      expect(formatter.format(BigInt.from(120000000000000)), equals('₳120M'));
      expect(
          formatter.format(BigInt.from(120000000000000000)), equals('₳120B'));
      expect(formatter.format(BigInt.from(9000000000000000000)), equals('₳9T'));
    });
    test('simpleCurrency', () {
      final formatter = AdaFormattter.simpleCurrency();
      logger.info(formatter.format(BigInt.from(120)));
      logger.info(formatter.format(BigInt.from(120000)));
      logger.info(formatter.format(BigInt.from(120000000)));
      logger.info(formatter.format(BigInt.from(120000000000)));
      logger.info(formatter.format(BigInt.from(120000000000000)));
      logger.info(formatter.format(BigInt.from(120000000000000000)));
      logger.info(formatter.format(BigInt.from(9000000000000000000)));
      expect(formatter.format(BigInt.from(120)), equals('ADA 0.000120'));
      expect(formatter.format(BigInt.from(120000)), equals('ADA 0.120000'));
      expect(
          formatter.format(BigInt.from(120000000)), equals('ADA 120.000000'));
      expect(formatter.format(BigInt.from(120000000000)),
          equals('ADA 120,000.000000'));
      expect(formatter.format(BigInt.from(120000000000000)),
          equals('ADA 120,000,000.000000'));
      expect(formatter.format(BigInt.from(120000000000000000)),
          equals('ADA 120,000,000,000.000000'));
      expect(formatter.format(BigInt.from(9000000000000000000)),
          equals('ADA 9,000,000,000,000.000000'));
    });
    test('simpleCurrencyEU', () {
      final formatter = AdaFormattter.simpleCurrency(locale: 'eu', name: 'ADA');
      //final f = formatter.format(BigInt.from(120);
      //logger.info("index8: ${f.codeUnitAt(8)}");
      //final suffix = utf8.decode([0xA0, 65, 68, 65]);
      logger.info(formatter.format(BigInt.from(120)));
      logger.info(formatter.format(BigInt.from(120000)));
      logger.info(formatter.format(BigInt.from(120000000)));
      logger.info(formatter.format(BigInt.from(120000000000)));
      logger.info(formatter.format(BigInt.from(120000000000000)));
      logger.info(formatter.format(BigInt.from(120000000000000000)));
      logger.info(formatter.format(BigInt.from(9000000000000000000)));
      //expect(formatter.format(BigInt.from(120)), equals('0,000120\u{00A0}ADA'));
      // expect(formatter.format(BigInt.from(120000)), equals('0,120000 ADA'));
      // expect(formatter.format(BigInt.from(120000000)), equals('120,000000 ADA'));
      // expect(formatter.format(BigInt.from(120000000000)), equals('120.000,000000 ADA'));
      // expect(formatter.format(BigInt.from(120000000000000)), equals('120.000.000,000000 ADA'));
      // expect(formatter.format(BigInt.from(120000000000000000)), equals('120.000.000.000,000000 ADA'));
      // expect(formatter.format(BigInt.from(9000000000000000000)), equals('9.000.000.000.000,000000 ADA'));
    });
    test('compactSimpleCurrency', () {
      final formatter = AdaFormattter.compactSimpleCurrency();
      logger.info(formatter.format(BigInt.from(120)));
      logger.info(formatter.format(BigInt.from(120000)));
      logger.info(formatter.format(BigInt.from(120000000)));
      logger.info(formatter.format(BigInt.from(120000000000)));
      logger.info(formatter.format(BigInt.from(120000000000000)));
      logger.info(formatter.format(BigInt.from(120000000000000000)));
      logger.info(formatter.format(BigInt.from(9000000000000000000)));
      expect(formatter.format(BigInt.from(120)), equals('ADA 0.000120'));
      expect(formatter.format(BigInt.from(120000)), equals('ADA 0.120000'));
      expect(formatter.format(BigInt.from(120000000)), equals('ADA 120'));
      expect(formatter.format(BigInt.from(120000000000)), equals('ADA 120K'));
      expect(
          formatter.format(BigInt.from(120000000000000)), equals('ADA 120M'));
      expect(formatter.format(BigInt.from(120000000000000000)),
          equals('ADA 120B'));
      expect(
          formatter.format(BigInt.from(9000000000000000000)), equals('ADA 9T'));
    });
  });
}
