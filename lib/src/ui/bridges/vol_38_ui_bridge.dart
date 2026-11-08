import "../../core/content/vol_38/vol_38_discourse.dart";
import "../../core/content/vol_38/vol_38_architecture_units.dart";
class Vol38UIBridge { static const int volume = 38, startTaskId = 2661, endTaskId = 2690; static Map<String, dynamic> getSummary() => {"volume": volume, "range": "$startTaskId-$endTaskId", "status": Vol38SystemsDiagnostics.runSelfDiagnostics() ? "OPTIMAL" : "DEGRADED"}; }
