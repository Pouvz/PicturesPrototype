using System;
using UnityEngine;
using UnityEngine.Serialization;

public class RoomCell : MonoBehaviour
{
    [TextArea(4, 10)]
    [SerializeField]
    private string designRules =
        "- Triggers of rooms must not overlap\n" +
        "- Triggers must cover the entire room\n" +
        "- The room after the next room must not be visible from the current room\n" +
        "- The room before the previous room must not be visible from the current room";
    
    [Tooltip("Leave empty if this is the first room")]
    [SerializeField] private RoomCell previousRoom;
    [SerializeField] private RoomCell[] nextRooms;

    private void Awake()
    {
        if (previousRoom == null)
        {
            Enter();
        }
    }

    public void Enter()
    {
        // The next cells are enabled
        foreach (RoomCell nextRoom in nextRooms)
        {
            nextRoom.gameObject.SetActive(true);
            
            // The next cells of the next cells are enabled
            foreach (RoomCell nextNextRoom in nextRoom.nextRooms)
            {
                nextNextRoom.gameObject.SetActive(enabled);
                
                // The next cells of the next cells of the next cells are disabled
                foreach (RoomCell nextNextNextRoom in nextNextRoom.nextRooms)
                {
                    nextNextNextRoom.gameObject.SetActive(false);
                }
            }
        }
        
        // The previous cell is enabled (if it exists)
        if (previousRoom != null)
        {
            previousRoom.gameObject.SetActive(true);
            
            // The cell before the previous cell is disabled (if it exists)
            if (previousRoom.previousRoom != null)
            {
                previousRoom.previousRoom.gameObject.SetActive(false);
            }
            
            // Disable all other next cells of the previous cell
            foreach (RoomCell previousNextRoom in previousRoom.nextRooms)
            {
                if (previousNextRoom != this)
                {
                    previousNextRoom.gameObject.SetActive(false);
                }
            }
        }
    }
}
