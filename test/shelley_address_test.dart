import 'package:cardano_wallet_sdk/src/address/hd_wallet.dart';
import 'package:cardano_wallet_sdk/src/address/shelley_address.dart';
import 'package:cardano_wallet_sdk/src/network/network_id.dart';
import 'package:test/test.dart';

void main() {
  final addr =
      'addr1qyy6nhfyks7wdu3dudslys37v252w2nwhv0fw2nfawemmn8k8ttq8f3gag0h89aepvx3xf69g0l9pf80tqv7cve0l33sdn8p3d';
  final addr_test =
      'addr_test1qqy6nhfyks7wdu3dudslys37v252w2nwhv0fw2nfawemmn8k8ttq8f3gag0h89aepvx3xf69g0l9pf80tqv7cve0l33sw96paj';
  final addr_test2 =
      'addr_test1qrqeavr4pa4vtzuf64m9z3cjke582vk7qvc6pcc6e5m9txa24kyuyck0xp0a7n7rah0gxj5mq3zdrc6xnaqph967c2kqcun0nj';

  group('shelley address test -', () {
    final testEntropy = '4e828f9a67ddcff0e6391ad4f26ddb7579f59ba14b6dd4baf63dcfdb9d2420da';
    final hdWallet = HdWallet.fromHexEntropy(testEntropy);
    final Bip32KeyPair spendPair = hdWallet.deriveAddressKeys(index: 0);
    //final Bip32KeyPair changePair = hdWallet.deriveAddress(role: changeRole, index: 0);
    final Bip32KeyPair stakePair = hdWallet.deriveAddressKeys(role: stakingRole, index: 0);
    test('network header', () {
      var a = ShelleyAddress.fromBech32(addr);
      expect(a.networkId, NetworkId.mainnet, reason: 'set mainnet bit in header');
      a = ShelleyAddress.fromBech32(addr_test);
      expect(a.networkId, NetworkId.testnet, reason: 'set testnet bit in header');
      a = ShelleyAddress.toBaseAddress(spend: spendPair.verifyKey!, stake: stakePair.verifyKey!);
      expect(a.networkId, NetworkId.testnet, reason: 'set testnet bit in header');
      expect(a.toBech32(), startsWith('addr_test1'), reason: 'set testnet bit in header');
      a = ShelleyAddress.toBaseAddress(
          spend: spendPair.verifyKey!, stake: stakePair.verifyKey!, networkId: NetworkId.mainnet);
      expect(a.networkId, NetworkId.mainnet, reason: 'set mainnet bit in header');
      expect(a.toBech32(), startsWith('addr1'), reason: 'set mainnet bit in header');
    });
    test('credential type header', () {
      var a = ShelleyAddress.toBaseAddress(spend: spendPair.verifyKey!, stake: stakePair.verifyKey!);
      expect(a.paymentCredentialType, CredentialType.Key, reason: 'key is default credential type');
      a = ShelleyAddress.toBaseAddress(
          spend: spendPair.verifyKey!, stake: stakePair.verifyKey!, paymentType: CredentialType.Script);
      expect(a.paymentCredentialType, CredentialType.Script, reason: 'override credential type');
    });
    test('address type header', () {
      var a = ShelleyAddress.toBaseAddress(spend: spendPair.verifyKey!, stake: stakePair.verifyKey!);
      expect(a.addressType, AddressType.Base, reason: 'toBaseAddress sets address type');
      a = ShelleyAddress.toRewardAddress(spend: spendPair.verifyKey!);
      expect(a.addressType, AddressType.Reward, reason: 'toRewardAddress sets address type');
    });
    test('address equals', () {
      var a = ShelleyAddress.fromBech32(addr_test);
      var b = ShelleyAddress.fromBech32(addr_test2);
      var c = ShelleyAddress.fromBech32(addr_test);
      expect(a == c, isTrue, reason: 'equals works');
      Set<ShelleyAddress> set = [a, b].toSet();
      expect(set.contains(c), isTrue, reason: 'equals works');
    });

    // test('bech32', () {
    //   final decoded = bech32.decode(addr, 108);
    //   final hrp = decoded.hrp;
    //   expect('addr', hrp);
    //   final addr2 = Bech32Coder(hrp: hrp).encode(decoded.data);
    //   expect(addr2, addr);
    // });
  });
}
