package br.com.fiap.zelo.repository;

import br.com.fiap.zelo.model.Cuidado;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface CuidadoRepository extends JpaRepository<Cuidado, Long>, JpaSpecificationExecutor<Cuidado> {
    List<Cuidado> findByPetId(Long petId);
}
