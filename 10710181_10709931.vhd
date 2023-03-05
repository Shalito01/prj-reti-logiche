----------------------------------------------------------------------------------
-- Company:
-- Engineer: Daniel Shala, Jurij Scandola
--
-- Create Date: 21.02.2023 22:24:23
-- Design Name:
-- Module Name: project_reti_logiche - prl0
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_w : in STD_LOGIC;

           o_z0 : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_z1 : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_z2 : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_z3 : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_done : out STD_LOGIC;

           o_mem_addr : out STD_LOGIC_VECTOR(15 DOWNTO 0);
           i_mem_data : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           o_mem_we : out STD_LOGIC;
           o_mem_en : out STD_LOGIC);
end project_reti_logiche;

architecture behavioral of project_reti_logiche is
    TYPE state_type IS (IDLE, CALC_ADDR, WAIT_RAM, GET_DATA, WRITE_OUT, DONE);
    SIGNAL state_curr, state_next : state_type;
    SIGNAL selected_out : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL o_mem_addr_next : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL count_w : INTEGER RANGE 0 TO 18 := 0;
    SIGNAL o_z0_next : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL o_z1_next : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL o_z2_next : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL o_z3_next : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL o_done_next : STD_LOGIC := '0';

BEGIN
    PROCESS (i_clk, i_rst)
    BEGIN
        IF(i_rst = '1') THEN
            state_curr <= IDLE;
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            o_mem_addr <= (others => '0');
            o_done <= '0';
        ELSIF (rising_edge(i_clk)) THEN
            state_curr <= state_next;
            o_mem_addr <= (others => '0');
            o_done <= o_done_next;
        END IF;
    END PROCESS;

    PROCESS(state_curr, i_start, i_w, selected_out, i_mem_data)
    BEGIN
        o_done_next <= '0';
        state_next <= state_curr;
        o_mem_addr_next <= "0000000000000000";

        CASE state_curr IS
            WHEN IDLE =>
                IF (i_start = '1') THEN
                    state_next <= CALC_ADDR;
                END IF;

            WHEN CALC_ADDR =>
                IF (i_start = '0') THEN
                    count_w <= 0;
                    state_next <= WAIT_RAM;
                ELSE
                    IF count_w < 2 THEN
                        selected_out <= selected_out(0) & i_w;
                    ELSIF (count_w >= 2 AND count_w < 18) THEN
                        o_mem_addr_next <= o_mem_addr_next(14 DOWNTO 0) & i_w;
                    END IF;
                    count_w <= count_w + 1;
                END IF;

            WHEN WAIT_RAM =>
                o_mem_addr <= o_mem_addr_next;
                o_mem_we <= '0';
                o_mem_en <= '1';
                state_next <= GET_DATA;

            WHEN GET_DATA =>
                CASE selected_out IS
                    WHEN "00" =>
                        o_z0_next <= i_mem_data;
                    WHEN "01" =>
                        o_z1_next <= i_mem_data;
                    WHEN "10" =>
                        o_z2_next <= i_mem_data;
                    WHEN "11" =>
                        o_z3_next <= i_mem_data;
                    WHEN others => null;
                END CASE;
                state_next <= WRITE_OUT;

            WHEN WRITE_OUT =>
                o_mem_en <= '0';
                o_done_next <= '1';
                o_z0 <= o_z0_next;
                o_z1 <= o_z1_next;
                o_z2 <= o_z2_next;
                o_z3 <= o_z3_next;
                state_next <= DONE;

            WHEN DONE =>
                o_done_next <= '0';
                count_w <= 0;
                state_next <= IDLE;
                o_z0 <= "00000000";
                o_z1 <= "00000000";
                o_z2 <= "00000000";
                o_z3 <= "00000000";

        END CASE;
    END PROCESS;
END behavioral;