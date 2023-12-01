using UnityEngine;
using UnityEngine.InputSystem;

public class TestController : MonoBehaviour
{
    private Vector2 _input;

    private void OnMove(InputValue value)
    {
        _input = value.Get<Vector2>();
    }
    
    private void Update()
    {
        transform.Translate(_input.x * (Time.deltaTime * 5f), 0 , _input.y * (Time.deltaTime * 5f));
    }
}
