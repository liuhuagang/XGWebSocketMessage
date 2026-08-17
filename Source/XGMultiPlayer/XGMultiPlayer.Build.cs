using UnrealBuildTool;

public class XGMultiPlayer : ModuleRules
{
	public XGMultiPlayer(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[] {
			"Core",
			"CoreUObject",
			"Engine",
			"InputCore",
			"EnhancedInput",
			"XGWebSocketMessage",
			"XGWebSocketClient",
			"XGWebSocketServer",
			"XGWebSocketGame",
			"XGWebSocketManage",
			"Json",
			"JsonUtilities"
		});
	}
}
