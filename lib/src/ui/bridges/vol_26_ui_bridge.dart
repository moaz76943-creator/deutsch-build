import "../../core/content/vol_26/vol_26_discourse.dart";
import "../../core/content/vol_26/vol_26_architecture_units.dart";
class Vol26UIBridge { static const int volume = 26, startTaskId = 2301, endTaskId = 2330; static Map<String, dynamic> getSummary() => {"volume": volume, "range": "$startTaskId-$endTaskId", "status": Vol26SystemsDiagnostics.runSelfDiagnostics() ? "OPTIMAL" : "DEGRADED"}; }
