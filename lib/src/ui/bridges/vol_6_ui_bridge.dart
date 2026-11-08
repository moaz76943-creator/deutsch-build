import "../../core/content/vol_6/vol_6_discourse.dart";
import "../../core/content/vol_6/vol_6_architecture_units.dart";
class Vol6UIBridge { static const int volume = 6, startTaskId = 1701, endTaskId = 1730; static Map<String, dynamic> getSummary() => {"volume": volume, "range": "$startTaskId-$endTaskId", "status": Vol6SystemsDiagnostics.runSelfDiagnostics() ? "OPTIMAL" : "DEGRADED"}; }
