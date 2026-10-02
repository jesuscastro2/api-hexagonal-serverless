package com.example.api.infrastructure.adapter.in.rest;

import com.example.api.application.service.UsuarioService;
import com.example.api.domain.model.Usuario;
import com.example.api.infrastructure.adapter.in.rest.dto.LoginRequest;
import com.example.api.infrastructure.adapter.in.rest.dto.LoginResponse;
import com.example.api.infrastructure.adapter.in.rest.dto.RegisterRequest;
import com.example.api.infrastructure.adapter.in.rest.dto.UsuarioResponse;
import com.example.api.infrastructure.security.JwtService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UsuarioService usuarioService;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthController(
            UsuarioService usuarioService,
            PasswordEncoder passwordEncoder,
            JwtService jwtService) {

        this.usuarioService = usuarioService;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @PostMapping("/register")
    public ResponseEntity<UsuarioResponse> registrar(
            @Valid @RequestBody RegisterRequest request) {

        Usuario usuario = new Usuario(
                null,
                request.getNombre(),
                request.getEmail(),
                request.getPassword(),
                "USER"
        );

        Usuario usuarioGuardado = usuarioService.guardar(usuario);

        UsuarioResponse respuesta = new UsuarioResponse(
                usuarioGuardado.getId(),
                usuarioGuardado.getNombre(),
                usuarioGuardado.getEmail(),
                usuarioGuardado.getRol()
        );

        return ResponseEntity.ok(respuesta);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @RequestBody LoginRequest request) {

        Usuario usuario = usuarioService
                .obtenerPorEmail(request.getEmail())
                .orElse(null);

        if (usuario == null) {
            return ResponseEntity
                    .status(401)
                    .body("Email o contraseña incorrectos");
        }

        boolean passwordCorrecta = passwordEncoder.matches(
                request.getPassword(),
                usuario.getPassword()
        );

        if (!passwordCorrecta) {
            return ResponseEntity
                    .status(401)
                    .body("Email o contraseña incorrectos");
        }

        String token = jwtService.generarToken(usuario);

        return ResponseEntity.ok(
                new LoginResponse(token)
        );
    }
}