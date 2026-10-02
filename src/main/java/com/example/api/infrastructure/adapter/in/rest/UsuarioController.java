package com.example.api.infrastructure.adapter.in.rest;

import com.example.api.application.service.UsuarioService;
import com.example.api.domain.model.Usuario;
import com.example.api.infrastructure.adapter.in.rest.dto.UsuarioRequest;
import com.example.api.infrastructure.adapter.in.rest.dto.UsuarioResponse;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioService usuarioService;

    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @GetMapping
    public ResponseEntity<List<UsuarioResponse>> obtenerTodos() {

        List<UsuarioResponse> usuarios = usuarioService
                .obtenerTodos()
                .stream()
                .map(this::convertirAResponse)
                .toList();

        return ResponseEntity.ok(usuarios);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UsuarioResponse> obtenerPorId(
            @PathVariable Long id) {

        return usuarioService.obtenerPorId(id)
                .map(this::convertirAResponse)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<UsuarioResponse> guardar(
            @Valid @RequestBody UsuarioRequest request) {

        Usuario usuario = new Usuario(
                null,
                request.getNombre(),
                request.getEmail(),
                request.getPassword(),
                "USER"
        );

        Usuario usuarioGuardado = usuarioService.guardar(usuario);

        return ResponseEntity.ok(
                convertirAResponse(usuarioGuardado)
        );
    }

    @PutMapping("/{id}")
    public ResponseEntity<UsuarioResponse> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody UsuarioRequest request) {

        if (usuarioService.obtenerPorId(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Usuario usuario = new Usuario(
                id,
                request.getNombre(),
                request.getEmail(),
                request.getPassword(),
                null
        );

        Usuario actualizado = usuarioService.actualizar(usuario);

        return ResponseEntity.ok(
                convertirAResponse(actualizado)
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(
            @PathVariable Long id) {

        if (usuarioService.obtenerPorId(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        usuarioService.eliminar(id);

        return ResponseEntity.noContent().build();
    }

    private UsuarioResponse convertirAResponse(Usuario usuario) {

        return new UsuarioResponse(
                usuario.getId(),
                usuario.getNombre(),
                usuario.getEmail(),
                usuario.getRol()
        );
    }
}