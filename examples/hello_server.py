"""Smallest useful FastMCP server, for checking that opencode can call MCP tools."""
from fastmcp import FastMCP

mcp = FastMCP("hello")


@mcp.tool
def add(a: int, b: int) -> int:
    """Add two integers."""
    return a + b


if __name__ == "__main__":
    mcp.run()
