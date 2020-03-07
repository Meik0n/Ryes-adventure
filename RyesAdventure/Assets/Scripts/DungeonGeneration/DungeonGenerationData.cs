using UnityEngine;

[CreateAssetMenu(fileName = "DungeonGenerationData", menuName = "DungeonGenerationData/Generation Data")]
public class DungeonGenerationData : ScriptableObject
{
    public int numberOfCrawlers;
    public int iterationMin;
    public int iterationMax;
}
