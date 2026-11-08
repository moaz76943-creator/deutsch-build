import "../../core/content/vol_27/vol_27_discourse.dart";
import "../../core/content/vol_27/vol_27_architecture_units.dart";
class Vol27UIBridge { static const int volume = 27, startTaskId = 2331, endTaskId = 2360; static Map<String, dynamic> getSummary() => {"volume": volume, "range": "$startTaskId-$endTaskId", "status": Vol27SystemsDiagnostics.runSelfDiagnostics() ? "OPTIMAL" : "DEGRADED"}; }
