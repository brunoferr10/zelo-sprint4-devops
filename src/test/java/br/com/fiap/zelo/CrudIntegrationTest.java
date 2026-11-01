package br.com.fiap.zelo;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
@SpringBootTest @AutoConfigureMockMvc @ActiveProfiles("test")
class CrudIntegrationTest {
 @Autowired MockMvc mvc;
 @Autowired ObjectMapper json;
 @Test void crudCompletoComRelacionamento() throws Exception {
  String body="{\"nome\":\"Mel\",\"especie\":\"Cao\",\"raca\":\"Beagle\",\"dataNascimento\":\"2023-04-12\",\"nomeTutor\":\"Bruno\"}";
  String result=mvc.perform(post("/api/pets").contentType("application/json").content(body)).andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
  long id=json.readTree(result).get("id").asLong();
  mvc.perform(get("/api/pets/"+id)).andExpect(status().isOk()).andExpect(jsonPath("$.nome").value("Mel"));
  mvc.perform(put("/api/pets/"+id).contentType("application/json").content(body.replace("Mel","Mel Atualizada"))).andExpect(status().isOk()).andExpect(jsonPath("$.nome").value("Mel Atualizada"));
  String cuidado="{\"petId\":"+id+",\"tipo\":\"CONSULTA\",\"descricao\":\"Retorno\",\"dataPrevista\":\"2026-12-01\",\"status\":\"PENDENTE\"}";
  result=mvc.perform(post("/api/cuidados").contentType("application/json").content(cuidado)).andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
  long cid=json.readTree(result).get("id").asLong();
  mvc.perform(get("/api/cuidados/"+cid)).andExpect(status().isOk());
  mvc.perform(put("/api/cuidados/"+cid).contentType("application/json").content(cuidado.replace("PENDENTE","CONCLUIDO"))).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("CONCLUIDO"));
  mvc.perform(delete("/api/cuidados/"+cid)).andExpect(status().isNoContent());
  mvc.perform(get("/api/cuidados/"+cid)).andExpect(status().isNotFound());
  mvc.perform(delete("/api/pets/"+id)).andExpect(status().isNoContent());
  mvc.perform(get("/api/pets/"+id)).andExpect(status().isNotFound());
 }
 @Test void rejeitaPetInvalido() throws Exception {
  mvc.perform(post("/api/pets").contentType("application/json").content("{}")).andExpect(status().isBadRequest());
 }
 @Test void retorna404ParaPetInexistente() throws Exception {
  mvc.perform(get("/api/pets/999999")).andExpect(status().isNotFound());
 }
}
