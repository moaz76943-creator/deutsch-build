import "../../core/content/vol_8/vol_8_discourse.dart";
import "../../core/content/vol_8/vol_8_architecture_units.dart";
class Vol8UIBridge { static const int volume = 8, startTaskId = 1761, endTaskId = 1790; static Map<String, dynamic> getSummary() => {"volume": volume, "range": "$startTaskId-$endTaskId", "status": Vol8SystemsDiagnostics.runSelfDiagnostics() ? "OPTIMAL" : "DEGRADED"}; }
