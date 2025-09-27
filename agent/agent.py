from google.adk.agents import Agent

# Define agent behavior
def get_project_info():
    """Get information about the Shadesmith project."""
    return {
        "project_name": "Shadesmith",
        "description": "A Flutter application project",
        "framework": "Flutter",
        "platforms": ["Android", "iOS", "Web", "macOS", "Windows", "Linux"]
    }

def calculate_shade_percentage(light_value: float, max_light: float = 100.0):
    """Calculate shade percentage based on light value."""
    if light_value < 0 or light_value > max_light:
        return {"error": "Light value must be between 0 and max_light"}
    
    shade_percentage = ((max_light - light_value) / max_light) * 100
    return {
        "light_value": light_value,
        "shade_percentage": round(shade_percentage, 2),
        "interpretation": "High shade" if shade_percentage > 70 else "Medium shade" if shade_percentage > 30 else "Low shade"
    }

# Create your agent
root_agent = Agent(
    name="shadesmith_agent",
    description="A helpful agent for the Shadesmith project",
    model="gemini-2.0-flash-exp",
    tools=[get_project_info, calculate_shade_percentage]
)