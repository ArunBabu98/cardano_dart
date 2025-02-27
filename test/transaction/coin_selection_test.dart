// Copyright 2021 Richard Easterling
// SPDX-License-Identifier: Apache-2.0

import 'package:cardano_wallet_sdk/cardano_wallet_sdk.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import '../wallet/mock_wallet_2.dart';

final ada = BigInt.from(1000000);
void main() {
  Logger.root.level = Level.WARNING; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final logger = Logger('CoinSelectionTest');
  final mockAdapter = BlockfrostBlockchainAdapter(
      blockfrost: buildMockBlockfrostWallet2(),
      network: Networks.testnet,
      projectId: '');
  final address = ShelleyAddress.fromBech32(stakeAddr2);
  final wallet = ReadOnlyWalletImpl(
    blockchainAdapter: mockAdapter,
    stakeAddress: address,
    walletName: 'mock wallet',
  );
  group('coin slection: largestFirst -', () {
    setUp(() async {
      //setup wallet
      final updateResult =
          await mockAdapter.updateWallet(stakeAddress: address);
      expect(updateResult.isOk(), isTrue);
      final update = updateResult.unwrap();
      wallet.refresh(
          balance: update.balance,
          usedAddresses: update.addresses,
          transactions: update.transactions,
          assets: update.assets,
          stakeAccounts: []);
      final filteredTxs = wallet.filterTransactions(assetId: lovelaceHex);
      expect(filteredTxs.length, equals(4));
      final unspentTxs = wallet.unspentTransactions;
      expect(unspentTxs.length, equals(2));
    });
    //Wallet UTxOs
    //tx.outputs[1].amounts: TransactionAmount(unit: 6c6f76656c616365 quantity: 99,228,617)
    //tx.outputs[1].amounts: TransactionAmount(unit: 6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7 quantity: 1)
    //tx.outputs[0].amounts: TransactionAmount(unit: 6c6f76656c616365 quantity: 100,000,000)

    test('setup coin selection - 99 ADA', () async {
      final lovelace = ada * BigInt.from(99);
      final result = await largestFirst(
        unspentInputsAvailable: wallet.unspentTransactions,
        spendRequest: FlatMultiAsset(
            fee: BigInt.from(200000), assets: {lovelaceHex: lovelace}),
        ownedAddresses: wallet.addresses.toSet(),
      );
      expect(result.isOk(), isTrue);
      final coins = result.unwrap();
      expect(coins.inputs.length, 1,
          reason: 'largest is 100 ADA and it covers 99 + fee');
      expect(coins.inputs[0].index, 0);
    });
    test('setup coin selection - 100 ADA', () async {
      final lovelace = ada * BigInt.from(100);
      final result2 = await largestFirst(
        unspentInputsAvailable: wallet.unspentTransactions,
        spendRequest: FlatMultiAsset(
            fee: BigInt.from(200000), assets: {lovelaceHex: lovelace}),
        ownedAddresses: wallet.addresses.toSet(),
      );
      expect(result2.isOk(), isTrue);
      final coins2 = result2.unwrap();
      expect(coins2.inputs.length, 2,
          reason: "largest is 100 ADA and it doesn't cover 100 + fee");
      expect(coins2.inputs[0].index, 0);
      expect(coins2.inputs[1].index, 1);
    });
    test('setup multi-asset coin selection - 99 ADA, 1 Test', () async {
      final result3 = await largestFirst(
        unspentInputsAvailable: wallet.unspentTransactions,
        spendRequest: FlatMultiAsset(fee: BigInt.from(200000), assets: {
          lovelaceHex: BigInt.from(99) * ada,
          '6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7':
              BigInt.one,
        }),
        ownedAddresses: wallet.addresses.toSet(),
      );
      expect(result3.isOk(), isTrue);
      final coins2 = result3.unwrap();
      expect(coins2.inputs.length, 1, reason: "takes 1 UTxOs");
      expect(coins2.inputs[0].index, 1);
    });

    test('insufficient funds error', () async {
      //setup coin selection - 200 ADA, which will result in insufficient funds error
      final result3 = await largestFirst(
        unspentInputsAvailable: wallet.unspentTransactions,
        spendRequest: FlatMultiAsset(
            fee: BigInt.from(200000),
            assets: {lovelaceHex: BigInt.from(200) * ada}),
        coinSelectionLimit: 4,
        ownedAddresses: wallet.addresses.toSet(),
      );
      expect(result3.isErr(), isTrue);
      expect(result3.unwrapErr().reason,
          CoinSelectionErrorEnum.inputValueInsufficient);
    });
    test('InputsExhausted', () async {
      //setup coin selection - 100 ADA and coinSelectionLimit = 1 - which will give InputsExhausted
      final result4 = await largestFirst(
        unspentInputsAvailable: wallet.unspentTransactions,
        spendRequest: FlatMultiAsset(
            fee: BigInt.from(200000),
            assets: {lovelaceHex: BigInt.from(100) * ada}),
        // outputsRequested: [BcMultiAsset.lovelace(100 * ada)],
        // estimatedFee: 200000,
        coinSelectionLimit: 1,
        ownedAddresses: wallet.addresses.toSet(),
      );
      expect(result4.isErr(), isTrue);
      expect(
          result4.unwrapErr().reason, CoinSelectionErrorEnum.inputsExhausted);
    });
  });

  group('FlatMultiAsset -', () {
    final clownName = str2hex.encode('clown');
    final clownPolicyId = str2hex.encode('ClownCoin');
    final clownId = clownPolicyId + clownName;
    final fuddName = str2hex.encode('fudd');
    final fuddPolicyId = str2hex.encode('ElmerFuddCoin');
    final fuddId = fuddPolicyId + fuddName;
    final u1 = UTxO(
      output: TransactionOutput(
          address: ShelleyAddress.fromBech32(
              'addr_test1vqy6nhfyks7wdu3dudslys37v252w2nwhv0fw2nfawemmnqtjtf68'),
          amounts: [
            TransactionAmount(
                unit: lovelaceHex, quantity: BigInt.from(10) * ada),
            TransactionAmount(unit: clownId, quantity: BigInt.from(100))
          ]),
      index: 0,
      transactionId: str2hex.encode('txId1'),
    );
    final u2 = UTxO(
      output: TransactionOutput(
          address: ShelleyAddress.fromBech32(
              'addr_test1vqy6nhfyks7wdu3dudslys37v252w2nwhv0fw2nfawemmnqtjtf68'),
          amounts: [
            TransactionAmount(
                unit: lovelaceHex, quantity: BigInt.from(11) * ada),
            TransactionAmount(unit: fuddId, quantity: BigInt.from(33))
          ]),
      index: 1,
      transactionId: str2hex.encode('txId2'),
    );
    test('add', () {
      final m1 =
          FlatMultiAsset(assets: {'a': BigInt.from(10), 'b': BigInt.from(15)});
      final m2 = m1.add(assetId: 'b', quantity: BigInt.from(15));
      expect(
          m2,
          equals(FlatMultiAsset(
              assets: {'a': BigInt.from(10), 'b': BigInt.from(30)})));
    });

    test('feeDefault', () {
      final m1 = FlatMultiAsset(assets: {}, fee: BigInt.two);
      expect(m1.fee, equals(BigInt.two));
      final m2 = FlatMultiAsset(assets: {});
      expect(m2.fee, equals(BigInt.zero));
    });

    test('utxosToMap', () {
      final m1 = FlatMultiAsset.utxosToMap([u1]);
      expect(
          MapEquality().equals(m1,
              {lovelaceHex: BigInt.from(10) * ada, clownId: BigInt.from(100)}),
          isTrue);
      final m2 = FlatMultiAsset.utxosToMap([u1, u2]);
      expect(
          MapEquality().equals(m2, {
            lovelaceHex: BigInt.from(21) * ada,
            clownId: BigInt.from(100),
            fuddId: BigInt.from(33)
          }),
          isTrue);
    });

    test('outputsRequestedToGoal', () {
      final request1 = MultiAssetBuilder(coin: BigInt.from(2) * ada)
          .nativeAsset(
              policyId: clownPolicyId,
              value: BigInt.from(100),
              hexName: clownName)
          .build();
      final m1 = FlatMultiAsset.outputsRequestedToGoal(request1);
      expect(
          MapEquality().equals(m1,
              {lovelaceHex: BigInt.from(2) * ada, clownId: BigInt.from(100)}),
          isTrue);
      final request2 = MultiAssetBuilder(coin: BigInt.from(10) * ada)
          .nativeAsset(
              policyId: clownPolicyId,
              value: BigInt.from(100),
              hexName: clownName)
          .nativeAsset(
              policyId: fuddPolicyId, value: BigInt.from(88), hexName: fuddName)
          .nativeAsset(
              policyId: '', value: BigInt.from(2) * ada, hexName: lovelaceHex)
          .build();
      final m2 = FlatMultiAsset.outputsRequestedToGoal(request2);
      expect(
          MapEquality().equals(m2, {
            lovelaceHex: BigInt.from(12) * ada,
            clownId: BigInt.from(100),
            fuddId: BigInt.from(88)
          }),
          isTrue);
    });

    test('funded', () {
      final estimatedFee = BigInt.from(175000);
      final request1 = MultiAssetBuilder(coin: BigInt.from(2) * ada)
          .nativeAsset(
              policyId: clownPolicyId,
              value: BigInt.from(100),
              hexName: clownName)
          .build();
      final target1 =
          FlatMultiAsset.outputsRequested(request1, fee: estimatedFee);
      expect(target1.funded([u1]), isTrue);
      final request2 = MultiAssetBuilder(coin: BigInt.from(10) * ada)
          .nativeAsset(
              policyId: clownPolicyId,
              value: BigInt.from(100),
              hexName: clownName)
          .build();
      final target2 =
          FlatMultiAsset.outputsRequested(request2, fee: estimatedFee);
      expect(target2.funded([u1]), isFalse, reason: 'not enough for fee');
      final request3 = MultiAssetBuilder(coin: BigInt.from(20) * ada)
          .nativeAsset(
              policyId: clownPolicyId,
              value: BigInt.from(100),
              hexName: clownName)
          .nativeAsset(
              policyId: fuddPolicyId, value: BigInt.from(33), hexName: fuddName)
          .build();
      final target3 =
          FlatMultiAsset.outputsRequested(request3, fee: estimatedFee);
      expect(target3.funded([u1, u2]), isTrue);
    });
  });
}
