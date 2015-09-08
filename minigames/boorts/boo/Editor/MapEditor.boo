namespace Pathfinding
import UnityEngine
import System
import System.Collections.Generic
import UnityEditor

[CustomEditor(Map2)]
class MapEditor(Editor):

	static aBaseName = "Map2"
	fred as Vector3
	
	_type_names as (string)
	
	override def OnInspectorGUI():
		if not _type_names:
			_type_names = [v for v in System.Enum.GetNames(MapType)].ToArray(string)
		MapTarget = target as Map2
		GUI.changed = false

		MapTarget.Width = EditorGUILayout.IntField("U", MapTarget.Width)
		MapTarget.Height = EditorGUILayout.IntField("V", MapTarget.Height)
	
		if GUI.changed:
			EditorUtility.SetDirty(MapTarget)
			Debug.Log("Dirty")
			
		for u in range(MapTarget.Width):
			for v in range (MapTarget.Height):
				display_item(u,v, MapTarget)


		if GUILayout.Button("Save"):
			Debug.Log("Saved")
			AssetDatabase.SaveAssets()

		if GUILayout.Button("Test"):
			for u in range(MapTarget.Width):
				for v in range (MapTarget.Height):
					Debug.Log(string.Format("{0},{1}: {2}",u,v,MapTarget[u,v] ))
	def display_item(u, v, _map as Map2):
		

		EditorGUILayout.BeginHorizontal()
		GUILayout.Label( string.Format("({0},{1})", u, v))
		try:
			index  = _map[u,v] cast int
			index = EditorGUILayout.Popup(index, _type_names)
			_map[u, v] = index cast MapType
		except:
			pass
		EditorGUILayout.EndHorizontal()



	[UnityEditor.MenuItem("Assets/Create/Map2", false, 101)]			
	static def CreateMap():
		
		new_map = ScriptableObject.CreateInstance(Map2)
		path = UnityEditor.AssetDatabase.GetAssetPath(UnityEditor.Selection.activeInstanceID)

		if System.IO.Path.GetExtension(path) != "":
			path = System.IO.Path.GetDirectoryName(path)
		if path  == "":
			path = "Assets";

		mapname = path + "/" + aBaseName + ".asset"
		id   = 0
		while (UnityEditor.AssetDatabase.LoadAssetAtPath(mapname, Map2) != null):
		    id  += 1
		    mapname = path + "/" + aBaseName + id + ".asset"

		UnityEditor.AssetDatabase.CreateAsset(new_map, mapname);
		UnityEditor.AssetDatabase.SaveAssets();
		UnityEditor.EditorUtility.FocusProjectWindow();
		UnityEditor.Selection.activeObject = new_map
		Debug.Log(mapname)



