package com.example.api.domain.ports.out;

import com.example.api.domain.model.Usuario;

import java.util.List;
import java.util.Optional;

public interface UsuarioRepositoryPort {

    Usuario guardar(Usuario usuario);

    List<Usuario> obtenerTodos();

    Optional<Usuario> obtenerPorId(Long id);

    Optional<Usuario> obtenerPorEmail(String email);

    Usuario actualizar(Usuario usuario);

    void eliminar(Long id);
}