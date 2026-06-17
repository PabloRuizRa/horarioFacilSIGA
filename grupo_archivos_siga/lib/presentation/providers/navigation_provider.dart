import 'package:flutter_riverpod/flutter_riverpod.dart';

// Este provider guardará el índice de la pestaña actual (0=Inicio, 1=Subir, 2=Horario)
final bottomNavProvider = StateProvider<int>((ref) => 0);