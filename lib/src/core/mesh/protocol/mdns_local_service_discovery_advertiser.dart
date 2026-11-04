/// Task 1501: Multicast DNS (mDNS) ZeroConf service advertiser
class MdnsServiceAdvertiser {
  String buildRecord(String packHash, int port) => '_polyglot._tcp.local:$port:$packHash';
}
