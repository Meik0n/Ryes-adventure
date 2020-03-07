using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ZombieToast : BaseEnemy
{
    [Header("Todavía no está terminado Kumi, no te pongas nervioso")]
    [Header("Zombie Toast")]
    public float normalStateSpeed = 4f;
    public float blobStateSpeed = 1f;
    public float attackRange = .2f;
    private PlayerController playerInstance;
    private States currentState;
    public LayerMask playerLayer;
    public GameObject attackPoint;
    private bool blobState = false;
    public Sprite blobSprite;

    private enum States
    {
        Chasing, Attacking, Explosion
    }

    void Start()
    {
        playerInstance = PlayerController.Instance;
        StartCoroutine(Chase());
    }

    void Update()
    {
        FaceCamera();

        if(!blobState && (currentHealth <= 1))
        {
            blobState = true;
            GetComponent<SpriteRenderer>().sprite = blobSprite;
        }
        Debug.Log(currentState);
        Debug.Log("Zombie vida: " + currentHealth);
    }

    private IEnumerator Chase()
    {
        currentState = States.Chasing;
        Collider[] detector;
        while (currentState == States.Chasing)
        {
            Vector3 target = playerInstance.transform.position;
            target.z = transform.position.z;

            if(!blobState)
            {
                transform.position = Vector3.MoveTowards(transform.position, target, normalStateSpeed * Time.deltaTime);
                detector = Physics.OverlapSphere(attackPoint.transform.position, attackRange, playerLayer);

                if (detector.Length >= 1)
                {
                    StartCoroutine(Attack());
                    yield break;
                }
            }
            else
            {
                transform.position = Vector3.MoveTowards(transform.position, target, blobStateSpeed * Time.deltaTime);
            }
            
            yield return null;
        }
    }

    private IEnumerator Attack()
    {
        currentState = States.Attacking;

        //animator.start animacion de ataque
        yield return new WaitForSeconds(1f); //poner despues el tiempo de la animacion de ataque

        Collider[] player = Physics.OverlapSphere(attackPoint.transform.position, attackRange, playerLayer);

        foreach (Collider c in player)
        {
            c.SendMessage("LoseLife", damage);
        }

        StartCoroutine(Chase());
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
}
