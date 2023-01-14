// Copyright 2021 Richard Easterling
// SPDX-License-Identifier: Apache-2.0

import 'package:cardano_wallet_sdk/cardano_wallet_sdk.dart';
import 'package:oxidized/oxidized.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'wallet/mock_wallet_2.dart';

///
/// insure documented tests are actually working code.
///
void main() {
  Logger.root.level = Level.WARNING; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final logger = Logger('ReadMe');
  const blockfrostKey = 'dummy-key';
  final mockAdapter = BlockfrostBlockchainAdapter(
      blockfrost: buildMockBlockfrostWallet2(),
      network: Networks.testnet,
      projectId: 'mock-id');
  final mnemonic =
      'chest task gorilla dog maximum forget shove tag project language head try romance memory actress raven resist aisle grunt check immense wrap enlist napkin'
          .split(' ');
  final formatter = AdaFormattter.compactSimpleCurrency();

  group('coding style -', () {
    test('WalletBuilders build method', () async {
      final walletBuilder = WalletBuilder();
      Result<Wallet, String> result = walletBuilder.build();
      result.when(
        ok: (wallet) => logger.info("Success: ${wallet.walletName}"),
        err: (message) => logger.info("Error: $message"),
      );
    });
  });

  group('wallet management -', () {
    test('Create a read-only wallet using a staking address', () async {
      const bechAddr =
          'stake_test1uz425a6u2me7xav82g3frk2nmxhdujtfhmf5l275dr4a5jc3urkeg';
      var address = ShelleyAddress.fromBech32(bechAddr);
      final walletBuilder = WalletBuilder()
        ..network = Networks.testnet
        ..testnetAdapterKey = blockfrostKey
        ..stakeAddress = address
        ..blockchainAdapter = mockAdapter;
      Result<ReadOnlyWallet, String> result =
          await walletBuilder.readOnlyBuildAndSync();
      result.when(
        ok: (wallet) => logger.info("${wallet.walletName}: ${wallet.balance}"),
        err: (message) => logger.info("Error: $message"),
      );
    });
    test('Restore existing wallet using 24 word mnemonic', () async {
      //List<String> mnemonic = 'rude stadium move...gallery receive just'.split(' ');
      final walletBuilder = WalletBuilder()
        ..network = Networks.testnet
        ..testnetAdapterKey = blockfrostKey
        ..mnemonic = mnemonic
        ..blockchainAdapter = mockAdapter;
      Result<Wallet, String> result = await walletBuilder.buildAndSync();
      if (result.isOk()) {
        var wallet = result.unwrap();
        logger.info("${wallet.walletName}: ${wallet.balance}");
      }
    });
    test('Update existing wallet', () async {
      final walletBuilder = WalletBuilder()
        ..network = Networks.testnet
        ..testnetAdapterKey = blockfrostKey
        ..mnemonic = mnemonic
        ..blockchainAdapter = mockAdapter;
      Result<Wallet, String> result = walletBuilder.build();
      Wallet wallet = result.unwrap();
      Coin oldBalance = wallet.balance;
      var result2 = await wallet.update();
      result2.when(
        ok: (_) =>
            logger.info("old:$oldBalance ADA, new: ${wallet.balance} ADA"),
        err: (message) => logger.info("Error: $message"),
      );
    });
    test('Create a new 24 word mnemonic', () {
      List<String> mnemonic =
          generateNewMnemonic(loadWordsFunction: loadEnglishMnemonicWords);
      logger.info("mnemonic: ${mnemonic.join(' ')}");
    });
    test('Send ADA to Bob', () async {
      var bobsAddress = ShelleyAddress.fromBech32(
          'addr_test1qqwncl938qg3sf46z8n878z26fnq426ttyarv3hk58keyzpxngwdkqgqcvjtzmz624d6efz67ysf3597k24uyzqg5ctsq32vnr');
      final adaAmount = 2 * 1000000;
      final walletBuilder = WalletBuilder()
        ..network = Networks.testnet
        ..testnetAdapterKey = blockfrostKey
        ..mnemonic = mnemonic
        ..blockchainAdapter = mockAdapter;
      final walletResult = await walletBuilder.buildAndSync();
      if (walletResult.isOk()) {
        var wallet = walletResult.unwrap();
        final Result<BcTransaction, String> result = await wallet.sendAda(
          toAddress: bobsAddress,
          lovelace: adaAmount,
        );
        if (result.isOk()) {
          final tx = result.unwrap();
          logger.info(
              "${formatter.format(adaAmount)} sent to Bob. Fee: ${tx.body.fee} lovelace");
        }
      }
    });

    test('Get the default (first) address from wallet', () {
      final wallet = (WalletBuilder()
            ..network = Networks.testnet
            ..testnetAdapterKey = blockfrostKey
            ..mnemonic = mnemonic
            ..blockchainAdapter = mockAdapter)
          .build()
          .unwrap();
      final ShelleyReceiveKit addr0 =
          wallet.account.unusedReceiveAddresses()[0];
      logger.info("${addr0.chain}: ${addr0.address}");
      //m/1852'/1815'/0'/0/0: addr_test1qputeu63ld6c0cd526w90ry2r9upc5ac8y3zetcg85xs5l924fm4c4hnud6cw53zj8v48kdwmeykn0knf74ag68tmf9sutu8kq
    });
  });
}
