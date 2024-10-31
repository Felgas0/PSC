#include <stdio.h>
#include <assert.h>

// Definição das estruturas
struct data {
    short flags:6;
    short length:10;
    short vals[];
};

struct info {
    double ref;
    struct data **data;
    int valid;
};

// Declaração da função assembly
extern short *get_val_ptr(struct info items[], size_t item_idx, size_t data_idx, size_t val_idx, short mask);

// Função de teste
void test_get_val_ptr() {
    // Definição dos dados estáticos
    static struct data data0 = { .flags = 0b000001, .length = 5, .vals = {0x0000, 0x0001, 0x0002, 0x0003, 0x0004} };
    static struct data data1 = { .flags = 0b000011, .length = 5, .vals = {0x0010, 0x0011, 0x0012, 0x0013, 0x0014} };
    static struct data data2 = { .flags = 0b001111, .length = 5, .vals = {0x0020, 0x0021, 0x0022, 0x0023, 0x0024} };
    static struct data data3 = { .flags = 0b111111, .length = 5, .vals = {0x0030, 0x0031, 0x0032, 0x0033, 0x0034} };

    static struct data *datas[] = {&data0, &data1, &data2, &data3};

    static struct info items[] = {
        { .ref = 3.5, .data = datas, .valid = 1 },
        { .ref = 1.5, .data = datas, .valid = 1 },
        { .ref = 3.5, .data = datas, .valid = 1 },
        { .ref = 1.5, .data = datas, .valid = 1 },
        { .ref = 0.0, .data = datas, .valid = 0 },
    };

    // Teste 1: Acessar o valor 0x0002 em data0
    short *result = get_val_ptr(items, 0, 0, 2, 0b000001);
    assert(result != NULL && *result == 0x0002);
    printf("Teste 1 passou: %p -> %d\n", result, *result);

    // Teste 2: Acessar o valor 0x0013 em data1
    result = get_val_ptr(items, 1, 1, 3, 0b000011);
    assert(result != NULL && *result == 0x0013);
    printf("Teste 2 passou: %p -> %d\n", result, *result);

    // Teste 3: Acessar o valor 0x0024 em data2
    result = get_val_ptr(items, 2, 2, 4, 0b001111);
    assert(result != NULL && *result == 0x0024);
    printf("Teste 3 passou: %p -> %d\n", result, *result);

    // Teste 4: Acessar o valor 0x0031 em data3
    result = get_val_ptr(items, 3, 3, 1, 0b111111);
    assert(result != NULL && *result == 0x0031);
    printf("Teste 4 passou: %p -> %d\n", result, *result);

    // Teste 5: Acessar um item inválido (deve retornar NULL)
    result = get_val_ptr(items, 4, 0, 0, 0b000001);
    assert(result == NULL);
    printf("Teste 5 passou: %p\n", result);

    // Teste 6: Acessar o valor 0x0000 em data0 com máscara diferente
    result = get_val_ptr(items, 0, 0, 0, 0b000001);
    assert(result != NULL && *result == 0x0000);
    printf("Teste 6 passou: %p -> %d\n", result, *result);

    // Teste 7: Acessar o valor 0x0011 em data1 com máscara diferente
    result = get_val_ptr(items, 1, 1, 1, 0b000011);
    assert(result != NULL && *result == 0x0011);
    printf("Teste 7 passou: %p -> %d\n", result, *result);

    // Teste 8: Acessar o valor 0x0023 em data2 com máscara diferente
    result = get_val_ptr(items, 2, 2, 3, 0b001111);
    assert(result != NULL && *result == 0x0023);
    printf("Teste 8 passou: %p -> %d\n", result, *result);

    // Teste 9: Acessar o valor 0x0034 em data3 com máscara diferente
    result = get_val_ptr(items, 3, 3, 4, 0b111111);
    assert(result != NULL && *result == 0x0034);
    printf("Teste 9 passou: %p -> %d\n", result, *result);

    // Teste 10: Acessar um item inválido com máscara diferente (deve retornar NULL)
    result = get_val_ptr(items, 4, 0, 0, 0b111111);
    assert(result == NULL);
    printf("Teste 10 passou: %p\n", result);
}

int main() {
    test_get_val_ptr();
    printf("Todos os testes passaram!\n");
    return 0;
}