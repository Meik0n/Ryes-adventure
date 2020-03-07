/**
 *  Copyright: Marcos Butrón Rúa   2020
 */

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    private static PlayerController instance;

    [Header("Health")]

    [Tooltip("Player's base health")]
    public ushort healthPoints = 5;
    private int currentHealth;


    [Header("Movement")]

    [Tooltip("The player movement speed")]
    public float movementSpeed = 5f;

    [Tooltip("The maximum Y axis value is 1.f, the X axis is the time of the animation")]
    public AnimationCurve cameraRotationAnimation = new AnimationCurve(new Keyframe(0, 0), new Keyframe(0.5f, 1f), new Keyframe(1f, 1f));
    private bool inputFlag = false;


    [Header("Attack")]

    [Tooltip("Player's base damage")]
    public ushort attackDamage = 1;

    [Tooltip("Drag here the point where the attack collision sphere will spawn")]
    public GameObject attackPoint;

    [Tooltip("The radius of the sphere collider for the attack")]
    public float attackRange;

    [Tooltip("The attack sphere collider will detect ONLY the gameobject in this layer")]
    public LayerMask enemyLayer;


    /// <summary>
    /// Awake is called when the script instance is being loaded.
    /// </summary>
    void Awake()
    {
        if (instance != null && instance != this)
        {
            Destroy(this.gameObject);
            return;
        }

        instance = this;

        currentHealth = healthPoints;
    }

    public static PlayerController Instance
    {
        get
        {
            return instance;
        }
    }

    void FixedUpdate()
    {
        GetMovementInput();
    }

    void Update()
    {
        GetInput();
    }


    /// <summary>
    /// GetMovementInput is called every fixed frame, it detects the player movement input.
    /// It's used in the FixedUpdate to avoid collision problems.
    /// </summary>
    private void GetMovementInput()
    {
        if (!inputFlag)
        {
            transform.Translate(Input.GetAxis("Horizontal") * Time.fixedDeltaTime * -movementSpeed,
                                0,
                                Input.GetAxis("Vertical") * Time.fixedDeltaTime * -movementSpeed);

        }
    }


    /// <summary>
    /// GetInput is called every frame, it detects the player input
    /// </summary>
    private void GetInput()
    {
        if (!inputFlag)
        {
            if (Input.GetButtonDown("Attack"))
            {
                Attack();
            }

            if (Input.GetButtonDown("RotateLeft"))
            {
                StartCoroutine(Rotate(Vector3.up, -90));
            }

            if (Input.GetButtonDown("RotateRight"))
            {
                StartCoroutine(Rotate(Vector3.up, 90));
            }
        }
    }


    /// <summary>
    /// Rotate is called when the player press the camera rotate button
    /// </summary>
    /// <param name="axis"> The axix around the player rotates.            </param>
    /// <param name="angle">The angle (in degrees) that the player rotates.</param>

    private IEnumerator Rotate(Vector3 axis, float angle)
    {
        Quaternion from = transform.rotation;
        Quaternion to = transform.rotation;      
      
        to *= Quaternion.Euler(axis * angle);
        
        float elapsed = 0.0f; /**<Time between coroutine starts and animation curve time*/

        while (elapsed < cameraRotationAnimation.keys[cameraRotationAnimation.keys.Length - 1].time)
        {
            inputFlag = true; /**<Blocks player input*/
            transform.rotation = Quaternion.Lerp(from, to, cameraRotationAnimation.Evaluate(elapsed)); /**<Lerps from current rotation to current rotation +- 90 degrees*/
            elapsed += Time.deltaTime;
            yield return null;
        }

        inputFlag = false;
        transform.rotation = to;
    }


    /// <summary>
    /// Attack is called when the player press the "attack" button.
    /// This fuction create a spherecast (raycast with spheres) in a point.
    /// The spherecast detects every gameobject overlapping with it in a layer.
    /// </summary>
    private void Attack()
    {
        Collider[] enemiesHitted = Physics.OverlapSphere(attackPoint.transform.position, attackRange, enemyLayer);

        foreach (Collider c in enemiesHitted)
        {
            c.SendMessage("LoseLife", attackDamage);
        }
    }

    void OnDrawGizmosSelected()
    {
        if (attackPoint == null)
        {
            return;
        }
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(attackPoint.transform.position, attackRange);
    }

    private void LoseLife(ushort damage)
    {
        currentHealth -= damage;
    }

    /// <summary>
    /// OnCollisionEnter is called when this collider/rigidbody has begun
    /// touching another rigidbody/collider.
    /// </summary>
    /// <param name="other">The Collision data associated with this collision.</param>
    private void OnCollisionEnter(Collision other)
    {

    }
}

