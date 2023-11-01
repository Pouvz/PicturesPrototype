using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class AdditionallyLoadScene : MonoBehaviour
{
    [SerializeField] private int sceneIndex = 1;
    
    private void OnTriggerEnter(Collider other)
    {

        // Unload all other aditionally loaded scenes
        for (int i = 0; i < SceneManager.sceneCount; i++)
        {
            Scene scene = SceneManager.GetSceneAt(i);
            if (scene.buildIndex != 0)
            {
                SceneManager.UnloadSceneAsync(scene);
            }
        }
            
        // Load new scene
        SceneManager.LoadScene(sceneIndex, LoadSceneMode.Additive);

    }
}