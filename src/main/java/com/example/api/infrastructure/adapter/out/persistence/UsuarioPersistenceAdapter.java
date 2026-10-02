package com.example.api.infrastructure.adapter.out.persistence;

import com.example.api.domain.model.Usuario;
import com.example.api.domain.ports.out.UsuarioRepositoryPort;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
public class UsuarioPersistenceAdapter implements UsuarioRepositoryPort {

    private final UsuarioJpaRepository usuarioJpaRepository;

    public UsuarioPersistenceAdapter(UsuarioJpaRepository usuarioJpaRepository) {
        this.usuarioJpaRepository = usuarioJpaRepository;
    }

    @Override
    public Usuario guardar(Usuario usuario) {
        UsuarioEntity entity = convertirAEntity(usuario);
        UsuarioEntity guardado = usuarioJpaRepository.save(entity);
        return convertirADominio(guardado);
    }

    @Override
    public List<Usuario> obtenerTodos() {
        return usuarioJpaRepository.findAll()
                .stream()
                .map(this::convertirADominio)
                .toList();
    }

    @Override
    public Optional<Usuario> obtenerPorId(Long id) {
        return usuarioJpaRepository.findById(id)
                .map(this::convertirADominio);
    }

    @Override
    public Optional<Usuario> obtenerPorEmail(String email) {
        return usuarioJpaRepository.findByEmail(email)
                .map(this::convertirADominio);
    }

    @Override
    public Usuario actualizar(Usuario usuario) {
        UsuarioEntity entity = convertirAEntity(usuario);
        UsuarioEntity actualizado = usuarioJpaRepository.save(entity);
        return convertirADominio(actualizado);
    }

    @Override
    public void eliminar(Long id) {
        usuarioJpaRepository.deleteById(id);
    }

    private UsuarioEntity convertirAEntity(Usuario usuario) {
        return new UsuarioEntity(
                usuario.getId(),
                usuario.getNombre(),
                usuario.getEmail(),
                usuario.getPassword(),
                usuario.getRol()
        );
    }

    private Usuario convertirADominio(UsuarioEntity entity) {
        return new Usuario(
                entity.getId(),
                entity.getNombre(),
                entity.getEmail(),
                entity.getPassword(),
                entity.getRol()
        );
    }
}