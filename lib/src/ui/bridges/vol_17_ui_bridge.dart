import "../../core/content/vol_17/vol_17_discourse.dart";
import "../../core/content/vol_17/vol_17_architecture_units.dart";
class Vol17UIBridge { static const int volume = 17, startTaskId = 2031, endTaskId = 2060; static Map<String, dynamic> getSummary() => {"volume": volume, "range": "$startTaskId-$endTaskId", "status": Vol17SystemsDiagnostics.runSelfDiagnostics() ? "OPTIMAL" : "DEGRADED"}; }
