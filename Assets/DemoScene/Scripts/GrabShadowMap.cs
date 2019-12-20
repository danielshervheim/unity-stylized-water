// Dan Shervheim, 2019
// danielshervheim.com

using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
[RequireComponent(typeof(Light))]
public class GrabShadowMap : MonoBehaviour
{
	[Tooltip("How will this shadow map be referenced in shaders?")]
	public string textureName = "_MainDirectionalShadowMap";
	
	private CommandBuffer cb = null;

	// When the editor loads, setup the shadow map copy pass.
	void OnEnable () 
	{
		Setup();
	}

	// If a change is made, set up the shadow map copy pass.
	void OnValidate()
	{
		Setup();
	}

	// When the game first starts, setup the shadow map copy pass.
	void Start()
	{
		Setup();
	}

	// When this light is destroyed, cleanup the shadow map copy pass.
	void OnDestroy()
	{
		Cleanup();
	}

	// Sets up a command buffer to copy the shadow map of this light.
	void Setup()
	{
		// Clean up any previously set command buffers.
		// (Maybe residual from executing in editor)?
		Cleanup();

		// Create and name new command buffer.
		cb = new CommandBuffer();
		cb.name = textureName + " (Shadow Map Copy)";

		// Set the global texture to be the just rendered shadow map.
		cb.SetGlobalTexture (textureName, new RenderTargetIdentifier(BuiltinRenderTextureType.CurrentActive));
		
		// Add the command buffer (right after shadows have been rendered) to this light.
		Light light = GetComponent<Light>();
		if (light != null)
		{
			light.AddCommandBuffer(LightEvent.AfterShadowMap, cb);
		}
	}

	void Cleanup()
	{
		// Remove all command buffers from this light.
		// (This is required because the script executes in the editor).
		Light light = GetComponent<Light>();
		if (light != null) 
		{
			light.RemoveAllCommandBuffers();
		}

		// Remove the globally set texture.
		Shader.SetGlobalTexture(textureName, null);
	}
}