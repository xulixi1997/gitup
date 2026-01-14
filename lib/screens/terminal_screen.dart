import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/settings_provider.dart';
import '../widgets/glitch_scaffold.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  List<String> _logs = [
    'GLITCH_OS v4.0.1 INITIALIZED...',
    'ACCESSING ROOT KERNEL...',
    'PERMISSION GRANTED.',
    'TYPE "help" FOR AVAILABLE COMMANDS.',
  ];

  @override
  void initState() {
    super.initState();
    // Keep focus on input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _addLog(String text) {
    setState(() {
      _logs.add(text);
    });
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _handleCommand(String input, SettingsProvider settings) {
    if (input.trim().isEmpty) return;

    _addLog('> $input');
    final parts = input.trim().split(' ');
    final command = parts[0].toLowerCase();
    final args = parts.length > 1 ? parts.sublist(1) : [];

    switch (command) {
      case 'help':
        _addLog('AVAILABLE COMMANDS:');
        _addLog('  set_gravity <val>    : Set gravity (def: 1000)');
        _addLog('  set_spawn_rate <val> : Set spawn rate multiplier (def: 1.0)');
        _addLog('  set_speed <val>      : Set player speed multiplier (def: 1.0)');
        _addLog('  unlock_all           : Unlock all fragments (CHEAT)');
        _addLog('  clear                : Clear terminal output');
        _addLog('  exit                 : Close terminal');
        break;

      case 'clear':
        setState(() {
          _logs.clear();
        });
        break;

      case 'exit':
        Navigator.pop(context);
        break;

      case 'set_gravity':
        if (args.isEmpty) {
          _addLog('ERROR: MISSING VALUE');
        } else {
          final val = double.tryParse(args[0]);
          if (val != null) {
            settings.setCustomRule('gravity', val);
            _addLog('SYSTEM UPDATE: GRAVITY SET TO $val');
          } else {
            _addLog('ERROR: INVALID NUMBER');
          }
        }
        break;

      case 'set_spawn_rate':
        if (args.isEmpty) {
          _addLog('ERROR: MISSING VALUE');
        } else {
          final val = double.tryParse(args[0]);
          if (val != null) {
            settings.setCustomRule('spawn_rate', val);
            _addLog('SYSTEM UPDATE: SPAWN RATE MULTIPLIER SET TO $val');
          } else {
            _addLog('ERROR: INVALID NUMBER');
          }
        }
        break;
        
      case 'set_speed':
        if (args.isEmpty) {
          _addLog('ERROR: MISSING VALUE');
        } else {
          final val = double.tryParse(args[0]);
          if (val != null) {
            settings.setCustomRule('speed_mult', val);
            _addLog('SYSTEM UPDATE: PLAYER SPEED MULTIPLIER SET TO $val');
          } else {
            _addLog('ERROR: INVALID NUMBER');
          }
        }
        break;

      case 'unlock_all':
        // TODO: Implement unlock logic if needed, or keep as placeholder
        _addLog('WARNING: CHEAT DETECTED. LOGGED.');
        break;

      default:
        _addLog('ERROR: UNKNOWN COMMAND "$command"');
    }

    _inputController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    return GlitchScaffold(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '// THE_TERMINAL (ROOT ACCESS)',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 20,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.greenAccent),
            
            // Output Area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Text(
                      _logs[index],
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Input Area
            Row(
              children: [
                const Text(
                  'admin@glitch:~\$ ',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    cursorColor: Colors.greenAccent,
                    onSubmitted: (value) => _handleCommand(value, settings),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
