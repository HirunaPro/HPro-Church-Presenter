#!/usr/bin/env python3
"""
Azure Cost Calculator for Church Presentation App
Helps estimate monthly costs based on usage patterns
"""

import sys
from datetime import datetime


class AzureCostCalculator:
    """Calculate Azure App Service costs based on usage patterns"""
    
    # Pricing (as of October 2025, prices in USD)
    PRICING = {
        'F1': {
            'name': 'Free Tier',
            'monthly': 0.00,
            'hourly': 0.00,
            'compute_minutes_per_day': 60,
            'always_on': False,
            'custom_domain': False,
            'websocket': True,
        },
        'B1': {
            'name': 'Basic B1',
            'monthly': 13.14,
            'hourly': 0.018,
            'compute_minutes_per_day': None,  # Unlimited
            'always_on': True,
            'custom_domain': True,
            'websocket': True,
        },
        'S1': {
            'name': 'Standard S1',
            'monthly': 69.35,
            'hourly': 0.095,
            'compute_minutes_per_day': None,
            'always_on': True,
            'custom_domain': True,
            'websocket': True,
        }
    }
    
    def __init__(self):
        self.tier = None
        self.usage_pattern = None
        
    def calculate_cost(self, tier, hours_per_week=None, days_per_week=None, 
                       hours_per_day=None, full_month=False):
        """
        Calculate monthly cost based on usage pattern
        
        Args:
            tier: 'F1', 'B1', or 'S1'
            hours_per_week: Total hours per week (for weekly pattern)
            days_per_week: Days per week the app runs (default: 7 for full month)
            hours_per_day: Hours per day the app runs (when running)
            full_month: If True, calculate for 24/7 operation
        """
        if tier not in self.PRICING:
            raise ValueError(f"Invalid tier. Choose from: {', '.join(self.PRICING.keys())}")
        
        tier_info = self.PRICING[tier]
        
        if tier == 'F1':
            # Free tier - always $0
            return {
                'tier': tier_info['name'],
                'monthly_cost': 0.00,
                'daily_cost': 0.00,
                'hourly_cost': 0.00,
                'notes': [
                    '✅ 60 minutes of compute time per day',
                    '⚠️ App sleeps after 20 minutes of inactivity',
                    '⚠️ Cold start delay (~10-30 seconds)',
                    '✅ WebSocket support included',
                    '💡 Perfect for Sunday-only services!'
                ]
            }
        
        # For paid tiers
        if full_month:
            # 24/7 operation
            monthly_cost = tier_info['monthly']
            daily_cost = monthly_cost / 30
            hourly_cost = tier_info['hourly']
            hours_used = 24 * 30
        else:
            # Partial usage
            days_per_week = days_per_week or 7
            hours_per_day = hours_per_day or 24
            
            if hours_per_week:
                # Weekly pattern
                hours_per_month = (hours_per_week * 52) / 12
            else:
                # Daily pattern
                hours_per_month = hours_per_day * days_per_week * 4.33  # Average weeks per month
            
            monthly_cost = hours_per_month * tier_info['hourly']
            daily_cost = monthly_cost / 30
            hourly_cost = tier_info['hourly']
            hours_used = hours_per_month
        
        notes = [
            f"✅ No sleep, always available",
            f"✅ WebSocket support included",
            f"✅ Custom domain support",
            f"📊 Estimated {hours_used:.1f} hours/month usage",
        ]
        
        if not full_month:
            savings = tier_info['monthly'] - monthly_cost
            notes.append(f"💰 Saves ${savings:.2f}/month vs 24/7 operation")
        
        return {
            'tier': tier_info['name'],
            'monthly_cost': monthly_cost,
            'daily_cost': daily_cost,
            'hourly_cost': hourly_cost,
            'hours_per_month': hours_used,
            'notes': notes
        }
    
    def print_comparison(self, usage_scenarios):
        """Print a comparison table for different usage scenarios"""
        print("\n" + "="*80)
        print("  AZURE APP SERVICE COST CALCULATOR - CHURCH PRESENTATION APP")
        print("="*80)
        
        for scenario in usage_scenarios:
            print(f"\n📋 SCENARIO: {scenario['name']}")
            print("-" * 80)
            print(f"Description: {scenario['description']}\n")
            
            for tier in ['F1', 'B1']:
                result = self.calculate_cost(
                    tier,
                    hours_per_week=scenario.get('hours_per_week'),
                    days_per_week=scenario.get('days_per_week'),
                    hours_per_day=scenario.get('hours_per_day'),
                    full_month=scenario.get('full_month', False)
                )
                
                print(f"  {result['tier']} ({tier})")
                print(f"  {'─' * 40}")
                print(f"    Monthly Cost:  ${result['monthly_cost']:.2f}")
                print(f"    Daily Cost:    ${result['daily_cost']:.2f}")
                print(f"    Hourly Rate:   ${result['hourly_cost']:.3f}")
                
                if 'hours_per_month' in result:
                    print(f"    Hours/Month:   {result['hours_per_month']:.1f}")
                
                print(f"\n    Notes:")
                for note in result['notes']:
                    print(f"      {note}")
                print()
        
        print("="*80)
        print("\n💡 RECOMMENDATIONS:\n")
        print("   • For Sunday-only services (2-3 hours):  Use FREE TIER (F1) = $0/month")
        print("   • For multiple weekly services:          Use FREE TIER (F1) = $0/month")
        print("   • For daily use + testing:               Use BASIC B1 (partial) = ~$2-6/month")
        print("   • For 24/7 availability:                 Use BASIC B1 (full) = ~$13/month")
        print("\n   💰 BEST VALUE: Start with FREE TIER and upgrade only if needed!")
        print("\n" + "="*80 + "\n")


def main():
    """Main function to run the cost calculator"""
    calculator = AzureCostCalculator()
    
    # Define common church usage scenarios
    scenarios = [
        {
            'name': 'Sunday Service Only',
            'description': 'Running only during Sunday morning service (2-3 hours/week)',
            'hours_per_week': 3,
        },
        {
            'name': 'Multiple Weekly Services',
            'description': 'Sunday morning + Wednesday evening (6 hours/week)',
            'hours_per_week': 6,
        },
        {
            'name': 'Daily Services',
            'description': 'Daily services, 2 hours per day, 7 days/week',
            'hours_per_day': 2,
            'days_per_week': 7,
        },
        {
            'name': 'Sunday Only (Running All Day)',
            'description': 'App running all day Sunday for testing (12 hours/week)',
            'hours_per_week': 12,
        },
        {
            'name': 'Development & Testing',
            'description': 'Active development, 4 hours/day, 5 days/week',
            'hours_per_day': 4,
            'days_per_week': 5,
        },
        {
            'name': '24/7 Always Available',
            'description': 'App always running for instant access',
            'full_month': True,
        }
    ]
    
    # Print comparison
    calculator.print_comparison(scenarios)
    
    # Interactive calculator
    print("\n📊 CUSTOM COST ESTIMATE")
    print("="*80)
    
    try:
        print("\nSelect your tier:")
        print("  1. Free Tier (F1)")
        print("  2. Basic B1")
        print("  3. Standard S1")
        
        tier_choice = input("\nEnter choice (1-3, or press Enter for Free Tier): ").strip()
        
        tier_map = {'1': 'F1', '2': 'B1', '3': 'S1', '': 'F1'}
        tier = tier_map.get(tier_choice, 'F1')
        
        if tier == 'F1':
            result = calculator.calculate_cost('F1')
            print(f"\n✅ Selected: {result['tier']}")
            print(f"\n   Monthly Cost: ${result['monthly_cost']:.2f}")
            print(f"\n   Notes:")
            for note in result['notes']:
                print(f"     {note}")
        else:
            print("\nSelect usage pattern:")
            print("  1. Hours per week")
            print("  2. Hours per day")
            print("  3. 24/7 (always on)")
            
            pattern_choice = input("\nEnter choice (1-3): ").strip()
            
            if pattern_choice == '1':
                hours = float(input("Hours per week: "))
                result = calculator.calculate_cost(tier, hours_per_week=hours)
            elif pattern_choice == '2':
                hours = float(input("Hours per day: "))
                days = int(input("Days per week: "))
                result = calculator.calculate_cost(tier, hours_per_day=hours, days_per_week=days)
            else:
                result = calculator.calculate_cost(tier, full_month=True)
            
            print(f"\n✅ Estimated Costs for {result['tier']}:")
            print(f"\n   Monthly Cost:  ${result['monthly_cost']:.2f}")
            print(f"   Daily Cost:    ${result['daily_cost']:.2f}")
            print(f"   Hourly Rate:   ${result['hourly_cost']:.3f}")
            
            if 'hours_per_month' in result:
                print(f"   Hours/Month:   {result['hours_per_month']:.1f}")
            
            print(f"\n   Notes:")
            for note in result['notes']:
                print(f"     {note}")
        
        print("\n" + "="*80 + "\n")
        
    except KeyboardInterrupt:
        print("\n\nCalculator closed.\n")
    except Exception as e:
        print(f"\nError: {e}\n")


if __name__ == "__main__":
    main()
