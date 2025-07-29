#!/usr/bin/env python3

import sys
import os
from datetime import datetime, timedelta
import pytz

# Add the current directory to Python path so we can import usage_analyzer
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from usage_analyzer.api import analyze_usage

# UTC timezone for calculations
UTC_TZ = pytz.UTC

def get_token_limit(plan, blocks=None):
    """Get token limit based on plan type."""
    limits = {"pro": 44000, "max5": 220000, "max20": 880000}
    
    if plan == "custom_max" and blocks:
        max_tokens = 0
        for block in blocks:
            if not block.get("isGap", False) and not block.get("isActive", False):
                tokens = block.get("totalTokens", 0)
                if tokens > max_tokens:
                    max_tokens = tokens
        return max_tokens if max_tokens > 0 else limits["pro"]
    
    return limits.get(plan, 44000)

def format_tokens(tokens):
    """Format token count for display."""
    if tokens >= 1000:
        return f"{tokens/1000:.1f}k"
    return str(tokens)

def calculate_hourly_burn_rate(blocks, current_time):
    """Calculate burn rate based on all sessions in the last hour."""
    if not blocks:
        return 0
    
    one_hour_ago = current_time - timedelta(hours=1)
    total_tokens = 0
    
    for block in blocks:
        start_time_str = block.get("startTime")
        if not start_time_str:
            continue
        
        # Parse start time
        start_time = datetime.fromisoformat(start_time_str.replace("Z", "+00:00"))
        if start_time.tzinfo is None:
            start_time = UTC_TZ.localize(start_time)
        else:
            start_time = start_time.astimezone(UTC_TZ)
        
        # Skip gaps
        if block.get("isGap", False):
            continue
        
        # Determine session end time
        if block.get("isActive", False):
            session_actual_end = current_time
        else:
            actual_end_str = block.get("actualEndTime")
            if actual_end_str:
                session_actual_end = datetime.fromisoformat(actual_end_str.replace("Z", "+00:00"))
                if session_actual_end.tzinfo is None:
                    session_actual_end = UTC_TZ.localize(session_actual_end)
                else:
                    session_actual_end = session_actual_end.astimezone(UTC_TZ)
            else:
                session_actual_end = current_time
        
        # Check if session overlaps with the last hour
        if session_actual_end < one_hour_ago:
            continue
        
        # Calculate portion of tokens used in the last hour
        session_start_in_hour = max(start_time, one_hour_ago)
        session_end_in_hour = min(session_actual_end, current_time)
        
        if session_end_in_hour <= session_start_in_hour:
            continue
        
        total_session_duration = (session_actual_end - start_time).total_seconds() / 60
        hour_duration = (session_end_in_hour - session_start_in_hour).total_seconds() / 60
        
        if total_session_duration > 0:
            session_tokens = block.get("totalTokens", 0)
            tokens_in_hour = session_tokens * (hour_duration / total_session_duration)
            total_tokens += tokens_in_hour
    
    return total_tokens / 60 if total_tokens > 0 else 0

def main():
    """Main function for waybar output."""
    try:
        # Get usage data
        data = analyze_usage()
        if not data or "blocks" not in data:
            sys.exit(2)  # API/connection error
        
        # Find active block
        active_block = None
        for block in data["blocks"]:
            if block.get("isActive", False):
                active_block = block
                break
        
        if not active_block:
            sys.exit(1)  # No active session
        
        # Extract data
        tokens_used = active_block.get("totalTokens", 0)
        plan = "pro"  # Default plan, could be made configurable
        token_limit = get_token_limit(plan, data["blocks"])
        
        # Auto-switch to custom_max if exceeded
        if tokens_used > token_limit:
            token_limit = get_token_limit("custom_max", data["blocks"])
        
        # Calculate metrics
        usage_percentage = (tokens_used / token_limit) * 100 if token_limit > 0 else 0
        tokens_left = token_limit - tokens_used
        
        # Calculate burn rate
        current_time = datetime.now(UTC_TZ)
        burn_rate = calculate_hourly_burn_rate(data["blocks"], current_time)
        
        # Time calculations
        start_time_str = active_block.get("startTime")
        end_time_str = active_block.get("endTime")
        
        if start_time_str:
            start_time = datetime.fromisoformat(start_time_str.replace("Z", "+00:00"))
            if start_time.tzinfo is None:
                start_time = UTC_TZ.localize(start_time)
            else:
                start_time = start_time.astimezone(UTC_TZ)
        
        if end_time_str:
            reset_time = datetime.fromisoformat(end_time_str.replace("Z", "+00:00"))
            if reset_time.tzinfo is None:
                reset_time = UTC_TZ.localize(reset_time)
            else:
                reset_time = reset_time.astimezone(UTC_TZ)
        else:
            # Fallback: 5 hours from start
            reset_time = start_time + timedelta(hours=5) if start_time_str else current_time + timedelta(hours=5)
        
        # Format output for waybar
        tokens_used_fmt = format_tokens(tokens_used)
        tokens_left_fmt = format_tokens(tokens_left)
        
        # Choose emoji based on usage
        if usage_percentage < 50:
            emoji = "🤖"
        elif usage_percentage < 80:
            emoji = "⚡"
        elif usage_percentage < 95:
            emoji = "🔥"
        else:
            emoji = "💀"
        
        # Create compact status line
        status = f"{emoji} {usage_percentage:.0f}% | {tokens_left_fmt} left"
        
        # Add warning indicators
        if tokens_used > token_limit:
            status += " ⚠️"
        elif burn_rate > 0 and tokens_left > 0:
            minutes_to_depletion = tokens_left / burn_rate
            time_to_reset = (reset_time - current_time).total_seconds() / 60
            if minutes_to_depletion < time_to_reset:
                status += " 🚨"
        
        print(status)
        
    except ImportError:
        # usage_analyzer not available
        print("❌ Claude: NO API")
        sys.exit(2)
    except Exception:
        # Any other error
        sys.exit(2)

if __name__ == "__main__":
    main() 