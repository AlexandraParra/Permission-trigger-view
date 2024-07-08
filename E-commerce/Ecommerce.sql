create database ecommerce;
use ecommerce;

create table clients(
    idClient int auto_increment primary_key,
    Fname varchar(10),
    Minit char(3),
    Lname varchar(20),
    CPF char(11) not null,
    Address varchar(30),
    constrain unique_cpf_client unique (CPF)
);

alter table clients auto_increment=1;

create table product(
    idProduct int auto_increment primary_key,
    Pname varchar(10) not null,
    Classification_kids boolean default false,
    category enum('Electrônico', 'Vestimenta', 'Brinquedos', 'Alimentos', 'Móveis') not null,
    assessment float default 0,
    size varchar(10)
);

create table payments(
    idClient int,
    idPayment int,
    typePayment enum('Boleto', 'Cartão', 'Dois cartões'),
    limitAvailable float,
    primary_key(idClient, idPayment)
);

create table orders(
    idOrder int auto_increment primary_key,
    idOrderClient int,
    orderStatus enum('Cancelado', 'Confirmado', 'Em processamento') default 'Em processamento',
    orderDescription varchar(255),
    sendValue float default 10,
    paymentCash boolean default false,
    idClient INT,
    idPayment INT,
    constrain fk_orders_client foreign key (idOrderClient) references clients(idClient),
    constrain fk_orders_payment foreign key (idClient, idPayment) references payments(idClient, idPayment)
);

create table productStorage(
    idProdStorage int auto_increment primary_key,
    storageLocation varchar(255),
    quantity int default 0
);

create table supplier(
    idSupplier int auto_increment primary_key,
    SocialName varchar(255) not null,
    CNPJ char(15) not null,
    concat char(11) not null,
    constrain unique_supplier unique (CNPJ)
);

create table seller(
    idSeller int auto_increment primary_key,
    SocialName varchar(255) not null,
    AbstName varchar(255),
    CNPJ char(15),
    CPF char(9),
    location varchar(255),
    concat char(11) not null,
    constrain unique_cnpj_seller unique (CNPJ),
    constrain unique_cpf_seller unique (CPF)
);

create table productSeller(
    idPseller int,
    idPproduct int,
    prodQuantity int default 1,
    primary_key(idPseller, idPproduct),
    constrain fk_product_seller foreign key (idPseller) references seller(idSeller),
    constrain fk_product_product foreign key (idPproduct) references product(idProduct)
);

create table productOrder(
    idPOproduct int,
    idPOorder int,
    poQuantity int default 1,
    poStatus enum('Disponível', 'Sem estoque') default 'Disponível',
    primary_key(idPOproduct, idPOorder),
    constrain fk_product_order_product foreign key (idPOproduct) references product(idProduct),
    constrain fk_product_order_order foreign key (idPOorder) references orders(idOrder)
);

create table storageLocation(
    idLproduct int,
    idLstorage int,
    location varchar(255) not null,
    primary_key(idLproduct, idLstorage),
    constrain fk_storage_location_product foreign key (idLproduct) references product(idProduct),
    constrain fk_storage_location_storage foreign key (idLstorage) references productStorage(idProdStorage)
);

create table productSupplier(
    idPsSupplier int,
    idPsProduct int,
    quantity int not null,
    primary_key(idPsSupplier, idPsProduct),
    constrain fk_product_supplier_supplier foreign key (idPsSupplier) references supplier(idSupplier),
    constrain fk_product_supplier_product foreign key (idPsProduct) references product(idProduct)
);

create table deletedClients(
    idClient int auto_increment primary_key,
    Fname varchar(10),
    Minit char(3),
    Lname varchar(20),
    CPF char(11),
    Address varchar(30),
);

-- Trigger before delete Client
DELIMITER $$

CREATE TRIGGER before_client_delete
BEFORE DELETE ON clients
FOR EACH ROW
BEGIN
    INSERT INTO deletedClients (Fname, Minit, Lname, CPF, Address)
    VALUES (OLD.Fname, OLD.Minit, OLD.Lname, OLD.CPF, OLD.Address);
END;

$$

DELIMITER ;

-- Trigger before update Product
DELIMITER //

CREATE TRIGGER before_product_update
BEFORE UPDATE ON product
FOR EACH ROW
BEGIN
    SET NEW.assessment = NEW.assessment * 1.30;
END;

//

DELIMITER ;