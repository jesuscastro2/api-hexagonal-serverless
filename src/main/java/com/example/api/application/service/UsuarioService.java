package com.example.api.application.service;

import com.example.api.domain.model.Usuario;
import com.example.api.domain.ports.out.UsuarioRepositoryPort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UsuarioService {

    private final UsuarioRepositoryPort usuarioRepositoryPort;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(
            UsuarioRepositoryPort usuarioRepositoryPort,
            PasswordEncoder passwordEncoder) {

        this.usuarioRepositoryPort = usuarioRepositoryPort;
        this.passwordEncoder = passwordEncoder;
    }

    public Usuario guardar(Usuario usuario) {

        String passwordEncriptada =
                passwordEncoder.encode(usuario.getPassword());

        usuario.setPassword(passwordEncriptada);

        return usuarioRepositoryPort.guardar(usuario);
    }

    public List<Usuario> obtenerTodos() {
        return usuarioRepositoryPort.obtenerTodos();
    }

    public Optional<Usuario> obtenerPorId(Long id) {
        return usuarioRepositoryPort.obtenerPorId(id);
    }

    public Optional<Usuario> obtenerPorEmail(String email) {
        return usuarioRepositoryPort.obtenerPorEmail(email);
    }

    public Usuario actualizar(Usuario usuario) {

        Optional<Usuario> existente =
                usuarioRepositoryPort.obtenerPorId(usuario.getId());

        if (existente.isEmpty()) {
            return null;
        }

        Usuario usuarioExistente = existente.get();

        usuario.setRol(usuarioExistente.getRol());

        String passwordEncriptada =
                passwordEncoder.encode(usuario.getPassword());

        usuario.setPassword(passwordEncriptada);

        return usuarioRepositoryPort.actualizar(usuario);
    }

    public void eliminar(Long id) {
        usuarioRepositoryPort.eliminar(id);
    }
}