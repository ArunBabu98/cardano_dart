// Copyright 2021 Richard Easterling
// SPDX-License-Identifier: Apache-2.0
// ignore_for_file: non_constant_identifier_names

import 'package:bip32_ed25519/api.dart';
import 'package:bip32_ed25519/bip32_ed25519.dart';
import './hd_derivation_chain.dart';
import './hd_icarus_key_derivation.dart';

///
/// This class implements a hierarchical deterministic wallet that generates cryptographic keys
/// given a root signing key. It also supports the creation/restoration of the root signing
/// key from a set of nmemonic BIP-39 words.
/// Cardano Shelley addresses are supported by default, but the code is general enough to support any
/// wallet based on the BIP32-ED25519 standard.
///
/// This code builds on following standards:
///
/// https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki - HD wallets
/// https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki - mnemonic words
/// https://github.com/bitcoin/bips/blob/master/bip-0043.mediawiki - Bitcoin purpose
/// https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki - multi-acct wallets
/// https://cips.cardano.org/cips/cip3/       - key generation
/// https://cips.cardano.org/cips/cip5/       - Bech32 prefixes
/// https://cips.cardano.org/cips/cip11/      - staking key
/// https://cips.cardano.org/cips/cip16/      - key serialisation
/// https://cips.cardano.org/cips/cip19/      - address structure
/// https://cips.cardano.org/cips/cip1852/    - 1852 purpose field
/// https://cips.cardano.org/cips/cip1855/    - forging keys
/// https://github.com/LedgerHQ/orakolo/blob/master/papers/Ed25519_BIP%20Final.pdf
///
///
/// BIP-44 path:
///     m / purpose' / coin_type' / account_ix' / change_chain / address_ix
///
/// Cardano adoption:
///     m / 1852' / 1851' / account' / role / index
///
///
class HdKeyDerivation {
  final IcarusKeyDerivation derivation;

  HdKeyDerivation(Bip32Key key) : derivation = IcarusKeyDerivation(key);

  HdKeyDerivation.entropy(Uint8List entropy)
      : derivation = IcarusKeyDerivation.entropy(entropy);

  HdKeyDerivation.entropyHex(String entropyHex)
      : derivation = IcarusKeyDerivation.entropyHex(entropyHex);

  // HdKeyDerivation.bech32(String root_sk)
  //     : derivation = IcarusKeyDerivation(codec.decode(root_sk));
  // HdKeyDerivation.rootKey(Bip32SigningKey rootKey)
  //     : derivation = IcarusKeyDerivation.import(codec.encode(rootKey));

  HdKeyDerivation.rootX(String root_xsk)
      : derivation = IcarusKeyDerivation.bech32Key(root_xsk);

  HdKeyDerivation.privateAcctX(String acct_xsk)
      : derivation = IcarusKeyDerivation.bech32Key(acct_xsk);

  HdKeyDerivation.pubicAcctX(String acct_xvk)
      : derivation = IcarusKeyDerivation.bech32Key(acct_xvk);

  Bip32Key get root => derivation.root;

  /// Derive key from root key and DerivationChain.
  Bip32Key fromChain(HdDerivationChain chain) {
    //print("HdKeyDerivation.fromChain: ${chain.toString()}");
    return derivation.pathToKey(chain.toString());
  }

  /// Derive key from root key and path.
  Bip32Key fromPath(String path) {
    //print("HdKeyDerivation.fromPath: ${path.toString()}");
    return derivation.pathToKey(path.toString());
  }

  //static const codec = Bech32Encoder(hrp: 'root_sk');
}
