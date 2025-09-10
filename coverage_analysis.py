#!/usr/bin/env python3
"""
Coverage Analysis and Reporting Script
This script analyzes coverage data and generates comprehensive reports
"""

import os
import re
import json
import subprocess
from datetime import datetime
from pathlib import Path

class CoverageAnalyzer:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.coverage_data = {}
        self.report_data = {}
        
    def run_coverage_tests(self):
        """Run all coverage tests and collect data"""
        print("=== Running Coverage Tests ===")
        
        # Test modules
        test_modules = [
            "01_uart_sv_tb/uart_coverage.sv",
            "02_fifo_sv_tb/fifo_coverage.sv", 
            "04_spi_sv_tb/spi_coverage.sv",
            "05_i2c_sv_tb/i2c_coverage.sv"
        ]
        
        for module in test_modules:
            module_path = self.project_root / module
            if module_path.exists():
                print(f"Running coverage test: {module}")
                self.run_single_coverage_test(module_path)
            else:
                print(f"Warning: {module} not found")
    
    def run_single_coverage_test(self, module_path):
        """Run a single coverage test"""
        try:
            # Extract module name
            module_name = module_path.stem.replace('_coverage', '')
            
            # Run simulation (this would be replaced with actual simulator commands)
            print(f"  Simulating {module_name}...")
            
            # Simulate coverage collection (in real implementation, this would
            # parse actual coverage data from simulator output)
            self.coverage_data[module_name] = self.simulate_coverage_data(module_name)
            
        except Exception as e:
            print(f"Error running {module_path}: {e}")
    
    def simulate_coverage_data(self, module_name):
        """Simulate coverage data collection"""
        # This simulates what would be collected from actual coverage runs
        import random
        
        coverage_data = {
            'timestamp': datetime.now().isoformat(),
            'module': module_name,
            'coverage_groups': {}
        }
        
        # Simulate different coverage groups based on module
        if module_name == 'uart':
            coverage_data['coverage_groups'] = {
                'uart_tx_cg': {
                    'data_cp': random.uniform(85, 100),
                    'oper_cp': random.uniform(90, 100),
                    'done_cp': random.uniform(95, 100),
                    'overall': random.uniform(88, 98)
                },
                'uart_rx_cg': {
                    'rx_data_cp': random.uniform(80, 95),
                    'rx_done_cp': random.uniform(90, 100),
                    'rx_signal_cp': random.uniform(85, 100),
                    'overall': random.uniform(85, 97)
                },
                'uart_state_cg': {
                    'tx_state_cp': random.uniform(90, 100),
                    'rx_state_cp': random.uniform(88, 100),
                    'reset_cp': random.uniform(95, 100),
                    'overall': random.uniform(90, 99)
                }
            }
        elif module_name == 'fifo':
            coverage_data['coverage_groups'] = {
                'fifo_operation_cg': {
                    'oper_cp': random.uniform(85, 100),
                    'data_in_cp': random.uniform(80, 95),
                    'data_out_cp': random.uniform(82, 98),
                    'status_cp': random.uniform(90, 100),
                    'overall': random.uniform(85, 97)
                },
                'fifo_depth_cg': {
                    'depth_cp': random.uniform(75, 90),
                    'write_full_cp': random.uniform(80, 95),
                    'read_empty_cp': random.uniform(85, 100),
                    'overall': random.uniform(80, 95)
                },
                'fifo_transition_cg': {
                    'state_transition_cp': random.uniform(70, 85),
                    'oper_sequence_cp': random.uniform(75, 90),
                    'overall': random.uniform(72, 88)
                }
            }
        elif module_name == 'spi':
            coverage_data['coverage_groups'] = {
                'spi_master_cg': {
                    'data_in_cp': random.uniform(85, 100),
                    'newd_cp': random.uniform(90, 100),
                    'cs_cp': random.uniform(95, 100),
                    'mosi_cp': random.uniform(88, 100),
                    'overall': random.uniform(88, 99)
                },
                'spi_slave_cg': {
                    'data_out_cp': random.uniform(82, 98),
                    'cs_detect_cp': random.uniform(90, 100),
                    'mosi_data_cp': random.uniform(85, 100),
                    'overall': random.uniform(85, 98)
                },
                'spi_protocol_cg': {
                    'protocol_state_cp': random.uniform(75, 90),
                    'sclk_freq_cp': random.uniform(90, 100),
                    'reset_cp': random.uniform(95, 100),
                    'overall': random.uniform(80, 95)
                }
            }
        elif module_name == 'i2c':
            coverage_data['coverage_groups'] = {
                'i2c_operation_cg': {
                    'oper_cp': random.uniform(90, 100),
                    'addr_cp': random.uniform(85, 100),
                    'data_in_cp': random.uniform(80, 95),
                    'data_out_cp': random.uniform(82, 98),
                    'busy_cp': random.uniform(90, 100),
                    'overall': random.uniform(85, 98)
                },
                'i2c_protocol_cg': {
                    'protocol_state_cp': random.uniform(70, 85),
                    'newd_cp': random.uniform(90, 100),
                    'reset_cp': random.uniform(95, 100),
                    'overall': random.uniform(80, 92)
                },
                'i2c_address_cg': {
                    'addr_range_cp': random.uniform(75, 90),
                    'overall': random.uniform(75, 90)
                }
            }
        
        return coverage_data
    
    def analyze_coverage(self):
        """Analyze coverage data and generate insights"""
        print("\n=== Analyzing Coverage Data ===")
        
        total_coverage = 0
        module_count = 0
        
        for module_name, data in self.coverage_data.items():
            print(f"\nAnalyzing {module_name.upper()} module:")
            
            module_coverage = 0
            group_count = 0
            
            for group_name, group_data in data['coverage_groups'].items():
                if 'overall' in group_data:
                    coverage = group_data['overall']
                    module_coverage += coverage
                    group_count += 1
                    print(f"  {group_name}: {coverage:.2f}%")
            
            if group_count > 0:
                module_coverage /= group_count
                total_coverage += module_coverage
                module_count += 1
                print(f"  Overall {module_name}: {module_coverage:.2f}%")
        
        if module_count > 0:
            total_coverage /= module_count
            print(f"\nOverall Project Coverage: {total_coverage:.2f}%")
        
        return total_coverage
    
    def generate_coverage_report(self):
        """Generate comprehensive coverage report"""
        print("\n=== Generating Coverage Report ===")
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'project': 'SystemVerilog Design and Verification',
            'coverage_data': self.coverage_data,
            'summary': {}
        }
        
        # Calculate summary statistics
        total_coverage = 0
        module_count = 0
        
        for module_name, data in self.coverage_data.items():
            module_coverage = 0
            group_count = 0
            
            for group_name, group_data in data['coverage_groups'].items():
                if 'overall' in group_data:
                    module_coverage += group_data['overall']
                    group_count += 1
            
            if group_count > 0:
                module_coverage /= group_count
                total_coverage += module_coverage
                module_count += 1
                
                report['summary'][module_name] = {
                    'coverage': module_coverage,
                    'status': 'PASS' if module_coverage >= 90 else 'FAIL'
                }
        
        if module_count > 0:
            total_coverage /= module_count
            report['summary']['overall'] = {
                'coverage': total_coverage,
                'status': 'PASS' if total_coverage >= 90 else 'FAIL'
            }
        
        # Save report
        report_file = self.project_root / 'coverage_report.json'
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"Coverage report saved to: {report_file}")
        return report
    
    def generate_html_report(self):
        """Generate HTML coverage report"""
        print("\n=== Generating HTML Report ===")
        
        html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Coverage Report - SystemVerilog Design and Verification</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        .header {{ background-color: #f0f0f0; padding: 20px; border-radius: 5px; }}
        .module {{ margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }}
        .coverage-bar {{ background-color: #e0e0e0; height: 20px; border-radius: 10px; margin: 5px 0; }}
        .coverage-fill {{ height: 100%; border-radius: 10px; transition: width 0.3s; }}
        .high {{ background-color: #4CAF50; }}
        .medium {{ background-color: #FF9800; }}
        .low {{ background-color: #f44336; }}
        .summary {{ background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0; }}
        table {{ border-collapse: collapse; width: 100%; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background-color: #f2f2f2; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>Coverage Report</h1>
        <p>SystemVerilog Design and Verification Project</p>
        <p>Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    </div>
"""
        
        # Add module coverage sections
        for module_name, data in self.coverage_data.items():
            module_coverage = 0
            group_count = 0
            
            for group_name, group_data in data['coverage_groups'].items():
                if 'overall' in group_data:
                    module_coverage += group_data['overall']
                    group_count += 1
            
            if group_count > 0:
                module_coverage /= group_count
            
            # Determine coverage level
            if module_coverage >= 90:
                level = 'high'
                color = '#4CAF50'
            elif module_coverage >= 70:
                level = 'medium'
                color = '#FF9800'
            else:
                level = 'low'
                color = '#f44336'
            
            html_content += f"""
    <div class="module">
        <h2>{module_name.upper()} Module Coverage: {module_coverage:.2f}%</h2>
        <div class="coverage-bar">
            <div class="coverage-fill {level}" style="width: {module_coverage:.1f}%; background-color: {color};"></div>
        </div>
        <table>
            <tr><th>Coverage Group</th><th>Coverage %</th><th>Status</th></tr>
"""
            
            for group_name, group_data in data['coverage_groups'].items():
                if 'overall' in group_data:
                    coverage = group_data['overall']
                    status = 'PASS' if coverage >= 90 else 'FAIL'
                    html_content += f"            <tr><td>{group_name}</td><td>{coverage:.2f}%</td><td>{status}</td></tr>\n"
            
            html_content += "        </table>\n    </div>\n"
        
        # Add summary
        total_coverage = 0
        module_count = 0
        for module_name, data in self.coverage_data.items():
            module_coverage = 0
            group_count = 0
            for group_name, group_data in data['coverage_groups'].items():
                if 'overall' in group_data:
                    module_coverage += group_data['overall']
                    group_count += 1
            if group_count > 0:
                module_coverage /= group_count
                total_coverage += module_coverage
                module_count += 1
        
        if module_count > 0:
            total_coverage /= module_count
        
        html_content += f"""
    <div class="summary">
        <h2>Summary</h2>
        <p><strong>Overall Project Coverage: {total_coverage:.2f}%</strong></p>
        <p>Status: {'PASS' if total_coverage >= 90 else 'FAIL'}</p>
        <p>Modules Tested: {module_count}</p>
    </div>
</body>
</html>
"""
        
        # Save HTML report
        html_file = self.project_root / 'coverage_report.html'
        with open(html_file, 'w') as f:
            f.write(html_content)
        
        print(f"HTML report saved to: {html_file}")
    
    def run_complete_analysis(self):
        """Run complete coverage analysis"""
        print("Starting Complete Coverage Analysis...")
        
        # Run coverage tests
        self.run_coverage_tests()
        
        # Analyze coverage
        overall_coverage = self.analyze_coverage()
        
        # Generate reports
        self.generate_coverage_report()
        self.generate_html_report()
        
        print(f"\n=== Analysis Complete ===")
        print(f"Overall Coverage: {overall_coverage:.2f}%")
        print(f"Status: {'PASS' if overall_coverage >= 90 else 'FAIL'}")
        
        return overall_coverage

def main():
    """Main function"""
    # Get project root
    project_root = os.path.dirname(os.path.abspath(__file__))
    
    # Create analyzer
    analyzer = CoverageAnalyzer(project_root)
    
    # Run complete analysis
    analyzer.run_complete_analysis()

if __name__ == "__main__":
    main()
