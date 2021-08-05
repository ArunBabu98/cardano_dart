// ; Shelley Types -  https://github.com/bloxbean/cardano-serialization-lib/blob/8c0f517ec39c333369462659b6c350223619973b/specs/shelley.cddl

// block =
//   [ header
//   , transaction_bodies         : [* transaction_body]
//   , transaction_witness_sets   : [* transaction_witness_set]
//   , transaction_metadata_set   : { * uint => transaction_metadata }
//   ]

// header =
//   ( header_body
//   , body_signature : $kes_signature
//   )

// header_body =
//   ( prev_hash        : $hash
//   , issuer_vkey      : $vkey
//   , vrf_vkey         : $vrf_vkey
//   , slot             : uint
//   , nonce            : uint
//   , nonce_proof      : $vrf_proof
//   , leader_value     : unit_interval
//   , leader_proof     : $vrf_proof
//   , size             : uint
//   , block_number     : uint
//   , block_body_hash  : $hash            ; merkle pair root
//   , operational_cert
//   , protocol_version
//   )

// operational_cert =
//   ( hot_vkey        : $kes_vkey
//   , cold_vkey       : $vkey
//   , sequence_number : uint
//   , kes_period      : uint
//   , sigma           : $signature
//   )

// protocol_version = (uint, uint, uint)

// ; Do we want to use a Map here? Is it actually cheaper?
// ; Do we want to add extension points here?
// transaction_body =
//   { 0 : #6.258([* transaction_input])
//   , 1 : [* transaction_output]
//   , ? 2 : [* delegation_certificate]
//   , ? 3 : withdrawals
//   , 4 : coin ; fee
//   , 5 : uint ; ttl
//   , ? 6 : full_update
//   , ? 7 : metadata_hash
//   }

// ; Is it okay to have this as a group? Is it valid CBOR?! Does it need to be?
// transaction_input = [transaction_id : $hash, index : uint]

// transaction_output = [address, amount : uint]

// address =
//  (  0, keyhash, keyhash       ; base address
//  // 1, keyhash, scripthash    ; base address
//  // 2, scripthash, keyhash    ; base address
//  // 3, scripthash, scripthash ; base address
//  // 4, keyhash, pointer       ; pointer address
//  // 5, scripthash, pointer    ; pointer address
//  // 6, keyhash                ; enterprise address (null staking reference)
//  // 7, scripthash             ; enterprise address (null staking reference)
//  // 8, keyhash                ; bootstrap address
//  )

// delegation_certificate =
//   [( 0, keyhash                       ; stake key registration
//   // 1, scripthash                    ; stake script registration
//   // 2, keyhash                       ; stake key de-registration
//   // 3, scripthash                    ; stake script de-registration
//   // 4                                ; stake key delegation
//       , keyhash                       ; delegating key
//       , keyhash                       ; key delegated to
//   // 5                                ; stake script delegation
//       , scripthash                    ; delegating script
//       , keyhash                       ; key delegated to
//   // 6, keyhash, pool_params          ; stake pool registration
//   // 7, keyhash, epoch                ; stake pool retirement
//   // 8                                ; genesis key delegation
//       , genesishash                   ; delegating key
//       , keyhash                       ; key delegated to
//   // 9, move_instantaneous_reward ; move instantaneous rewards
//  ) ]

// move_instantaneous_reward = { * keyhash => coin }
// pointer = (uint, uint, uint)

// credential =
//   (  0, keyhash
//   // 1, scripthash
//   // 2, genesishash
//   )

// pool_params = ( #6.258([* keyhash]) ; pool owners
//               , coin                ; cost
//               , unit_interval       ; margin
//               , coin                ; pledge
//               , keyhash             ; operator
//               , $vrf_keyhash        ; vrf keyhash
//               , [credential]        ; reward account
//               )

// withdrawals = { * [credential] => coin }

// full_update = [ protocol_param_update_votes, application_version_update_votes ]

// protocol_param_update_votes =
//   { * genesishash => protocol_param_update }

// protocol_param_update =
//   { ? 0:  uint               ; minfee A
//   , ? 1:  uint               ; minfee B
//   , ? 2:  uint               ; max block body size
//   , ? 3:  uint               ; max transaction size
//   , ? 4:  uint               ; max block header size
//   , ? 5:  coin               ; key deposit
//   , ? 6:  unit_interval      ; key deposit min refund
//   , ? 7:  rational           ; key deposit decay rate
//   , ? 8:  coin               ; pool deposit
//   , ? 9:  unit_interval      ; pool deposit min refund
//   , ? 10: rational           ; pool deposit decay rate
//   , ? 11: epoch              ; maximum epoch
//   , ? 12: uint               ; n_optimal. desired number of stake pools
//   , ? 13: rational           ; pool pledge influence
//   , ? 14: unit_interval      ; expansion rate
//   , ? 15: unit_interval      ; treasury growth rate
//   , ? 16: unit_interval      ; active slot coefficient
//   , ? 17: unit_interval      ; d. decentralization constant
//   , ? 18: uint               ; extra entropy
//   , ? 19: [protocol_version] ; protocol version
//   }

// application_version_update_votes = { * genesishash => application_version_update }

// application_version_update = { * application_name =>  [uint, application_metadata] }

// application_metadata = { * system_tag => installerhash }

// application_name = tstr .size 12
// system_tag = tstr .size 10

// transaction_witness_set =
//   (  0, vkeywitness
//   // 1, $script
//   // 2, [* vkeywitness]
//   // 3, [* $script]
//   // 4, [* vkeywitness],[* $script]
//   )

// transaction_metadata =
//     { * transaction_metadata => transaction_metadata }
//   / [ * transaction_metadata ]
//   / int
//   / bytes
//   / text

// vkeywitness = [$vkey, $signature]

// unit_interval = rational

// rational =  #6.30(
//    [ numerator   : uint
//    , denominator : uint
//    ])

// coin = uint
// epoch = uint

// keyhash = $hash

// scripthash = $hash

// genesishash = $hash

// installerhash = $hash

// metadata_hash = $hash

// $hash /= bytes

// $vkey /= bytes

// $signature /= bytes

// $vrf_keyhash /= bytes

// $vrf_vkey /= bytes
// $vrf_proof /= bytes

// $kes_vkey /= bytes

// $kes_signature /= bytes

import 'package:cbor/cbor.dart';
import 'package:hex/hex.dart';
import 'dart:convert';

///
/// translation from java: https://github.com/bloxbean/cardano-client-lib/tree/master/src/main/java/com/bloxbean/cardano/client/transaction/spec
///
class ShelleyAsset {
  final String name;
  final int value;

  ShelleyAsset({required this.name, required this.value});

  ///name is stored in hex in ledger. Try Hex decode first. If fails, try string.getBytes (used in mint transaction from client)
  List<int> getNameAsBytes() {
    try {
      return name.startsWith('0x') ? HEX.decode(name.substring(2)) : HEX.decode(name);
    } catch (e) {
      return utf8.encode(name);
    }
  }
}

class ShelleyMultiAsset {
  final String policyId;
  final List<ShelleyAsset> assets;

  ShelleyMultiAsset({required this.policyId, required this.assets});

  void serialize(MapBuilder multiAssetMap) {
    final mb = MapBuilder.builder();
    for (ShelleyAsset asset in assets) {
      mb.writeString(asset.name); //key
      mb.writeInt(asset.value);
    }
    multiAssetMap.writeString(policyId); //key
    multiAssetMap.addBuilderOutput(mb.getData());
  }

  static ShelleyMultiAsset deserialize(Map multiAssetsMap, String key) {
    List<ShelleyAsset> assets = [];
    String policyId = '';
    // final data = codec2.getDecodedData()!;
    // ByteString keyBS = (ByteString) key;
    // String policyId = (HEX.encode(keyBS.getBytes()));

    // Map assetsMap = (Map) multiAssetsMap.get(key);
    // for(DataItem assetKey: assetsMap.getKeys()) {
    //     ByteString assetNameBS = (ByteString)assetKey;
    //     UnsignedInteger assetValueUI = (UnsignedInteger)(assetsMap.get(assetKey));

    //     String name = HEX.encode(assetNameBS.getBytes());
    //     assets.add(ShelleyAsset(name:name, value:assetValueUI.getValue()));
    // }
    return ShelleyMultiAsset(policyId: policyId, assets: assets);
  }
}

class ShelleyTransactionInput {
  final String transactionId;
  final int index;

  ShelleyTransactionInput({required this.transactionId, required this.index});

  // public Array serialize() throws CborSerializationException {
  //     Array inputArray = new Array();
  //     byte[] transactionIdBytes = HexUtil.decodeHexString(transactionId);
  //     inputArray.add(new ByteString(transactionIdBytes));
  //     inputArray.add(new UnsignedInteger(index));

  //     return inputArray;
  // }
}

class ShelleyTransactionOutput {
  final String address;
  final ShelleyValue value;

  ShelleyTransactionOutput({required this.address, required this.value});

  //transaction_output = [address, amount : value]
  // public Array serialize() throws CborSerializationException, AddressExcepion {
  //     Array array = new Array();
  //     byte[] addressByte = Account.toBytes(address);
  //     array.add(new ByteString(addressByte));

  //     if(value == null)
  //         throw new CborSerializationException("Value cannot be null");

  //     if(value.getMultiAssets() != null && value.getMultiAssets().size() > 0) {
  //         Array coinAssetArray = new Array();

  //         if(value.getCoin() != null)
  //             coinAssetArray.add(new UnsignedInteger(value.getCoin()));

  //         Map valueMap = value.serialize();
  //         coinAssetArray.add(valueMap);

  //         array.add(coinAssetArray);

  //     } else {
  //         array.add(new UnsignedInteger(value.getCoin()));
  //     }

  //     return array;
  // }
}

class ShelleyValue {
  final int coin;
  //Policy Id -> Asset
  final List<ShelleyMultiAsset> multiAssets;

  ShelleyValue({required this.coin, required this.multiAssets});

  // public Map serialize() throws CborSerializationException {
  //     Map map = new Map();
  //     if(multiAssets != null) {
  //         for (MultiAsset multiAsset : multiAssets) {
  //             Map assetsMap = new Map();
  //             for (Asset asset : multiAsset.getAssets()) {
  //                 ByteString assetNameBytes = new ByteString(asset.getNameAsBytes());
  //                 UnsignedInteger value = new UnsignedInteger(asset.getValue());
  //                 assetsMap.put(assetNameBytes, value);
  //             }

  //             ByteString policyIdByte = new ByteString(HexUtil.decodeHexString(multiAsset.getPolicyId()));
  //             map.put(policyIdByte, assetsMap);
  //         }
  //     }
  //     return map;
  // }
}

class ShelleyTransactionBody {
  final List<ShelleyTransactionInput> inputs;
  final List<ShelleyTransactionOutput> outputs;
  final int fee;
  final int? ttl; //Optional
  final List<int>? metadataHash;
  final int? validityStartInterval;
  final List<ShelleyMultiAsset>? mint;

  ShelleyTransactionBody({
    required this.inputs,
    required this.outputs,
    required this.fee,
    this.ttl,
    this.metadataHash,
    this.validityStartInterval,
    this.mint,
  });

  MapBuilder toCborMap({required Encoder encoder}) {
    final mapBuilder = MapBuilder.builder();
    //0:inputs
    mapBuilder.writeInt(0);
    mapBuilder.writeArray([]);
    //1:outputs
    mapBuilder.writeInt(1);
    mapBuilder.writeArray([]);
    //2:fee
    mapBuilder.writeInt(2);
    mapBuilder.writeInt(fee);
    //3:ttl (optional)
    if (ttl != null) {
      mapBuilder.writeInt(3);
      mapBuilder.writeInt(ttl!);
    }
    //7:metadataHash (optional)
    if (metadataHash != null && metadataHash!.isNotEmpty) {
      mapBuilder.writeInt(7);
      mapBuilder.writeString('');
    }
    //8:validityStartInterval (optional)
    if (validityStartInterval != null) {
      mapBuilder.writeInt(8);
      mapBuilder.writeInt(validityStartInterval!);
    }
    //9:mint (optional)
    if (mint != null && mint!.isNotEmpty) {
      mapBuilder.writeInt(9);
      mapBuilder.writeArray([]);
    }
    return mapBuilder;
  }

  // Map serialize() throws CborSerializationException, AddressExcepion {
  //     Map bodyMap = new Map();

  //     Array inputsArray = new Array();
  //     for(TransactionInput ti: inputs) {
  //         Array input = ti.serialize();
  //         inputsArray.add(input);
  //     }
  //     bodyMap.put(new UnsignedInteger(0), inputsArray);

  //     Array outputsArray = new Array();
  //     for(TransactionOutput to: outputs) {
  //         Array output = to.serialize();
  //         outputsArray.add(output);
  //     }
  //     bodyMap.put(new UnsignedInteger(1), outputsArray);

  //    bodyMap.put(new UnsignedInteger(2), new UnsignedInteger(fee)); //fee

  //    if(ttl != 0) {
  //        bodyMap.put(new UnsignedInteger(3), new UnsignedInteger(ttl)); //ttl
  //    }

  //    if(metadataHash != null) {
  //        bodyMap.put(new UnsignedInteger(7), new ByteString(metadataHash));
  //    }

  //    if(validityStartInterval != 0) {
  //        bodyMap.put(new UnsignedInteger(8), new UnsignedInteger(validityStartInterval)); //validityStartInterval
  //    }

  //     if(mint != null && mint.size() > 0) {
  //         Map mintMap = new Map();
  //         for(MultiAsset multiAsset: mint) {
  //             multiAsset.serialize(mintMap);
  //         }
  //         bodyMap.put(new UnsignedInteger(9), mintMap);
  //     }

  //     return bodyMap;
  // }
}

class ShelleyTransactionWitnessSet {}

class ShelleyMetadata {}

class ShelleyTransaction {
  final ShelleyTransactionBody body;
  final ShelleyTransactionWitnessSet? witnessSet;
  final ShelleyMetadata? metadata;

  ShelleyTransaction({required this.body, this.witnessSet, this.metadata});

  ListBuilder toCborList({required Encoder encoder}) {
    final listBuilder = ListBuilder.builder();
    listBuilder.addBuilderOutput(body.toCborMap(encoder: encoder).getData());
    if (witnessSet == null) {
      listBuilder.writeArray([]);
    } else {
      listBuilder.writeArray([]); //TODO
    }
    if (metadata == null) {
      listBuilder.writeNull();
    } else {
      listBuilder.writeArray([]); //TODO
    }
    return listBuilder;
  }

  List<int> serialize({Cbor? cbor}) {
    final _cbor = cbor ?? Cbor();
    final encoder = _cbor.encoder;
    return toCborList(encoder: encoder).getData();
  }

  String get toCborHex => HEX.encode(serialize());

  // public byte[] serialize() throws CborSerializationException {
  //     try {
  //         if (metadata != null && body.getMetadataHash() == null) {
  //             byte[] metadataHash = metadata.getMetadataHash();
  //             body.setMetadataHash(metadataHash);
  //         }

  //         ByteArrayOutputStream baos = new ByteArrayOutputStream();
  //         CborBuilder cborBuilder = new CborBuilder();

  //         Array array = new Array();
  //         Map bodyMap = body.serialize();
  //         array.add(bodyMap);

  //         //witness
  //         if (witnessSet != null) {
  //             Map witnessMap = witnessSet.serialize();
  //             array.add(witnessMap);
  //         } else {
  //             Map witnessMap = new Map();
  //             array.add(witnessMap);
  //         }

  //         //metadata
  //         if (metadata != null) {
  //             array.add(metadata.getData());
  //         } else
  //             array.add(new ByteString((byte[]) null)); //Null for meta

  //         cborBuilder.add(array);

  //         new CborEncoder(baos).nonCanonical().encode(cborBuilder.build());
  //         byte[] encodedBytes = baos.toByteArray();
  //         return encodedBytes;
  //     } catch (Exception e) {
  //         throw new CborSerializationException("CBOR Serialization failed", e);
  //     }
  // }
}