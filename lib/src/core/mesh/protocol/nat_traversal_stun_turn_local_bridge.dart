/// Task 1508: Local subnet hole-punching and bridge relay
class LocalSubnetBridge {
  bool canDirectConnect(String ip1, String ip2) => ip1.split('.').take(3).join('.') == ip2.split('.').take(3).join('.');
}
