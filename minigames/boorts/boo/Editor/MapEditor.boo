namespace Pathfinding
import UnityEngine
import System
import System.Collections.Generic
import UnityEditor

[CustomEditor(Map)]
class MapEditor(Editor):

	static aBaseName = "Map"
	fred as Vector3
	
	
	override def OnInspectorGUI():
		MapTarget = target as Map
		GUI.changed = false

		MapTarget.Width = EditorGUILayout.IntField("U", MapTarget.Width)
		MapTarget.Height = EditorGUILayout.IntField("V", MapTarget.Height)
		if GUI.changed:
			EditorUtility.SetDirty(MapTarget)
			Debug.Log("Dirty")

		fred = EditorGUILayout.Vector3Field("Fred", fred)
		
		if GUILayout.Button("Set"):
			ad = Address(fred.x cast int, fred.y cast int)
			bob as Cell = Cell()
			if fred.z > 1:
				bob = Hills()
			
			MapTarget.cell_set(ad, bob)
			EditorUtility.SetDirty(MapTarget)
			Debug.Log("Dirty")
		GUI.changed = false



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



