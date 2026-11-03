use sakila;

delimiter $$

create function copias_pelicula(pelicula int, tienda int)
returns int
reads sql data
begin
    declare cantidad int;

    select count(*) into cantidad
    from inventory
    where film_id = pelicula
    and store_id = tienda;

    return cantidad;
end $$

delimiter ;

select copias_pelicula(1, 1);
select copias_pelicula(5, 2);


delimiter $$

create procedure clientes_pais(in pais varchar(50), out lista text)
begin
    declare terminado int default 0;
    declare nombre varchar(100);

    declare cursor_clientes cursor for
        select concat(c.first_name, " ", c.last_name)
        from customer c
        join address a on c.address_id = a.address_id
        join city ci on a.city_id = ci.city_id
        join country co on ci.country_id = co.country_id
        where co.country = pais;

    declare continue handler for not found set terminado = 1;

    set lista = "";

    open cursor_clientes;

    recorrer: loop
        fetch cursor_clientes into nombre;

        if terminado = 1 then
            leave recorrer;
        end if;

        if lista = "" then
            set lista = nombre;
        else
            set lista = concat(lista, ";", nombre);
        end if;

    end loop;

    close cursor_clientes;
end $$

delimiter ;

call clientes_pais("Argentina", @lista);
select @lista;

call clientes_pais("Canada", @lista);
select @lista;


-- ejercicio 3

-- inventory_in_stock

show create function inventory_in_stock;

-- esta funcion recibe el id de una copia y revisa si esta disponible.
-- primero cuenta si esa copia tuvo alquileres.
-- si nunca fue alquilada devuelve true.
-- si ya fue alquilada revisa si tiene algun alquiler sin fecha de devolucion.
-- si todavia no fue devuelta devuelve false, si ya fue devuelta devuelve true.

select inventory_in_stock(1);
select inventory_in_stock(10);


-- film_in_stock

show create procedure film_in_stock;

-- este procedimiento recibe el id de una pelicula y el id de una tienda.
-- busca las copias de esa pelicula en esa tienda y usa inventory_in_stock
-- para comprobar cuales estan disponibles.
-- despues usa found_rows() para guardar la cantidad en el parametro de salida.
-- tambien muestra los ids de las copias disponibles.

call film_in_stock(1, 1, @cantidad);
select @cantidad;

call film_in_stock(5, 2, @cantidad);
select @cantidad;

-- diferencia:
-- inventory_in_stock verifica si una copia esta disponible.
-- film_in_stock busca las copias disponibles de una pelicula en una tienda
-- y devuelve la cantidad.