namespace Pathfinding
import UnityEngine
import System
import System.Collections.Generic
import UnityEditor


class MapEditor(EditorWindow):

	static aBaseName = "Map"
	
	[UnityEditor.MenuItem("Assets/Create/Map", false, 101)]			
	static def CreateMap():
		
		new_map = ScriptableObject.CreateInstance(Map)
		path = UnityEditor.AssetDatabase.GetAssetPath(UnityEditor.Selection.activeInstanceID)

		if System.IO.Path.GetExtension(path) != "":
			path = System.IO.Path.GetDirectoryName(path)
		if path  == "":
			path = "Assets";

		mapname = path + "/" + aBaseName + ".asset"
		id   = 0
		while (UnityEditor.AssetDatabase.LoadAssetAtPath(mapname, Map) != null):
		    id  += 1
		    mapname = path + "/" + aBaseName + id + ".asset"

		UnityEditor.AssetDatabase.CreateAsset(new_map, mapname);
		UnityEditor.AssetDatabase.SaveAssets();
		UnityEditor.EditorUtility.FocusProjectWindow();
		UnityEditor.Selection.activeObject = new_map
		Debug.Log(mapname)
