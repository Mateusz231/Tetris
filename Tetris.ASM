program segment
org 100h
assume cs:program

start:

;graphics mode 
mov ah,00h
mov al,13h
int 10h

mov cx,200
call draw_border_left
mov cx,200
call draw_border_right
mov cx,79
call draw_border_bottom



;call draw_block_start_O
call get_seed
call modify_seed
call generate_random_number
call draw_block_start_I

random_seed dw 0
c_par dw 1
a_par dw 3
m_par dw 80

current_block db 0
current_x_left_border dw 0
current_x_right_border dw 0
current_y_upper_bound dw 0
current_y_lower_bound dw 0
current_color db 0
currently_moving db 1
cant_shift_left db 0
cant_shift_right db 0
rotate_state db 0
can_transform_var db 0
delay_var dw 40000
skip_delay_var db 0
current_colision_status db 0
old_x_left_border dw 0
old_x_right_border dw 0
old_y_upper_bound dw 0
old_y_lower_bound dw 0









main_loop:


call read_input

call arrows

call exit

call delay_loop

call remove_previous_block

call move_block

call check_for_collision_start

call can_shift_left

call can_shift_right

call gen_next_block



jmp main_loop





read_input:
    mov ah, 01h  
    int 16h
    jz no_key_pressed 

			
	key:
	
	mov ah,07h
	int 21h
	cmp al,00h
	je key
	
	ret 

	no_key_pressed:
	ret
	



exit:

cmp al,esc_key
je esc_key_read 

ret


esc_key_read:
    mov ah, 4Ch      
    int 21h
	
	ret 
	

arrows:

cmp al,down_arrow
je skip_delay

cmp al,left_arrow
je shift_left

cmp al,right_arrow
je shift_right

cmp al,up_arrow
je block_transform


mov cl,0
mov skip_delay_var,cl
ret 





skip_delay:
mov cl,1
mov skip_delay_var,1
ret 


shift_left:
call shift_left_2
ret 





shift_right:
call shift_right_2
ret




block_transform:
call block_transform_2
ret















draw_border_left:
push cx

mov ah,0cH
mov dx, cx
mov al,0fh
mov bh,00h
mov cx,79
int 10h

pop cx 
dec cx

jnz draw_border_left





ret 

draw_border_right:
push cx

mov ah,0cH
mov dx, cx
mov al,0fh
mov bh,00h
mov cx,240
int 10h




pop cx 
dec cx

jnz draw_border_right

ret 
	


draw_border_bottom:


mov ah,0ch
mov al,0fh
mov bh,00h
mov dx,199
int 10h
inc cx

cmp cx,240
je draw_end
jmp draw_border_bottom

draw_end:
ret










draw_block_start_O:


mov cx,160
mov dx,00h
mov current_x_left_border,cx
mov current_x_right_border,179
mov current_y_upper_bound,dx
mov current_y_lower_bound,20


draw_block_O:
mov ah,0cH
mov current_color,al 
mov bh,00h
int 10h

inc cx



cmp cx,current_x_right_border
jg increment_y

jmp draw_block_O 


increment_y:
mov cx,current_x_left_border
inc dx
cmp dx,current_y_lower_bound
je end_block_draw_O
jmp draw_block_O

end_block_draw_O:
mov ah,2
mov current_block,ah
mov currently_moving,ah
mov ah,0
mov current_colision_status,0
ret






















draw_block_start_I:
mov cx,160
mov dx,00h
mov current_x_left_border,cx
mov current_x_right_border,169
mov current_y_upper_bound,dx
mov current_y_lower_bound,40




draw_block_I:
mov ah,0cH
mov current_color,al
mov bh,00h
int 10h



inc cx



cmp cx,current_x_right_border
jg increment_y_6

jmp draw_block_I 


increment_y_6:

mov cx, current_x_left_border
inc dx
cmp dx,current_y_lower_bound
je end_block_draw_I
jmp draw_block_I

end_block_draw_I:
mov ah,1
mov current_block,ah
mov currently_moving,ah
mov ah,0
mov rotate_state,0
mov current_colision_status,0
ret






























move_block:

cmp currently_moving,0
je not_moving


mov cx,current_x_left_border
mov dx,current_y_lower_bound
inc dx
mov current_y_lower_bound,dx
mov dx,current_y_upper_bound
inc dx
mov current_y_upper_bound,dx





move_block_innner:
mov ah,0cH
mov al,current_color
mov bh,00h
int 10h

inc cx
cmp cx,current_x_right_border
jg increment_y_3

jmp move_block_innner


increment_y_3:
mov cx,current_x_left_border
inc dx
cmp dx,current_y_lower_bound
je move_block_end
jmp move_block_innner




move_block_end:
ret



not_moving:
ret












remove_previous_block:

cmp currently_moving,0
je not_moving


mov cx,current_x_left_border
mov dx,current_y_upper_bound

remove_previous_row:
mov ah,0cH
mov al,00h
mov bh,00h
int 10h


inc cx

cmp cx,current_x_right_border
jg end_block_remove




jmp remove_previous_row


end_block_remove:

ret














check_for_collision_start:
mov dx,current_y_lower_bound
mov cx,current_x_left_border



check_for_collision:



mov ah,0dh
mov bh,00h
int 10h


inc cx
cmp cx,current_x_right_border
jg colission_not_true 



cmp al,00h
jne collision_true



jmp check_for_collision




ret

collision_true:
mov currently_moving,0
mov current_colision_status,1
ret

colission_not_true:
ret















delay_loop:

	cmp skip_delay_var,0
	je const_delay
	
	
	
	mov delay_var,30
	mov cx,delay_var
	jmp delay_inner_loop
	
	
	
	

	const_delay:
	mov delay_var,10000
	


    mov cx, delay_var  
	delay_inner_loop:
    dec cx         
    jnz delay_inner_loop 
    ret           
















gen_next_block:

cmp current_colision_status,1
je gen_next_shape 

ret

gen_next_shape:
call get_seed
call modify_seed
call generate_random_number
call draw_block_start_O

ret





can_shift_left:

mov cx,current_x_left_border
mov dx,current_y_upper_bound
dec cx



can_shift_left_loop:


mov ah,0dh
mov bh,00h
int 10h 

inc dx

cmp al,00h
jne left_negative


cmp dx,current_y_lower_bound
je left_positive


jmp can_shift_left_loop

left_negative: 
mov cl,1
mov cant_shift_left,cl
ret

left_positive:
mov cl,0
mov cant_shift_left,cl
ret




can_shift_right:

mov cx,current_x_right_border
mov dx,current_y_upper_bound
inc cx



can_shift_right_loop:


mov ah,0dh
mov bh,00h
int 10h 

inc dx

cmp al,00h
jne right_negative


cmp dx,current_y_lower_bound
je right_positive


jmp can_shift_right_loop

right_negative: 
mov cl,1
mov cant_shift_right,cl
ret

right_positive:
mov cl,0
mov cant_shift_right,cl
ret





get_seed:

  mov ah, 2Ch    
 int 21h        
 push dx       
 xor dx, dx     
 mov cx, 1000h   
 div cx         
 pop dx         
 mov random_seed, dx  
 ret


modify_seed:
	mov ax, random_seed    
    mul a_par        
    add ax, c_par    
    mov dx, 0
    div m_par      
    mov random_seed, dx    
    ret
     


generate_random_number:
	 mov ax, random_seed  
    xor dx, dx          
    mov cx, 5          
	div cx               
	cmp dl,15
	jge minus2
	ret

	minus2:
	cmp dl,15
	jl generate_random_number_end

	cmp dl,0
	je add_one


	sub dl,15
	jmp minus2

	ret


generate_random_number_end:
mov current_color,dl
ret

add_one:
inc dl
mov current_color,dl
ret



shift_left_2:


mov cx,current_x_left_border
mov dx,current_y_upper_bound



cmp cant_shift_left,1
je exit_shift_left







remove_previous_block_2:
mov ah,0cH
mov al,000h
mov bh,00h
int 10h
inc cx

cmp cx,current_x_right_border
jg increment_y_4

jmp remove_previous_block_2


increment_y_4:
mov cx,current_x_left_border
inc dx
cmp dx,current_y_lower_bound
je remove_previous_end_2
jmp remove_previous_block_2


remove_previous_end_2:
sub current_x_left_border,10
sub current_x_right_border,10
ret

exit_shift_left:
ret

shift_right_2:

mov dx,current_y_upper_bound
mov cx,current_x_left_border

cmp cant_shift_right,1
je exit_shift_right



remove_previous_block_3:
mov ah,0cH
mov al,000h
mov bh,00h
int 10h
inc cx

cmp cx,current_x_right_border
jg increment_y_5

jmp remove_previous_block_3


increment_y_5:
mov cx,current_x_left_border
inc dx
cmp dx,current_y_lower_bound
je remove_previous_end_3
jmp remove_previous_block_3


remove_previous_end_3:
add current_x_left_border,10
add current_x_right_border,10
ret

exit_shift_right:
ret



block_transform_2:

cmp current_block,1
je I_block

cmp current_block,2
je O_block

cmp current_block,3
je Z_block

cmp current_block,4
je S_block

cmp current_block,5 
je J_block

cmp current_block,6
je T_block

cmp current_block,7
je L_block



I_block:

cmp rotate_state,0
je rotate_I

cmp rotate_state,1
je rotate_I_2

ret

rotate_I:
call can_transform
call transform_I_block_1 
ret

rotate_I_2:
call can_transform_2
call transform_I_block_2
ret


O_block:
ret

Z_block:
ret

S_block:
ret

J_block:
ret

T_block:
ret

L_block:
ret









ret






















transform_I_block_1:

cmp can_transform_var,1
je cannot_transform


call remove_block
mov ax,current_x_left_border
mov dx,current_x_right_border
mov cx,current_y_lower_bound
mov bx,current_y_upper_bound



sub dx,ax
sub cx,bx

mov bx,current_y_upper_bound
add bx,dx
mov current_y_lower_bound,bx

mov bx,current_x_left_border
add bx,cx
mov current_x_right_border,bx




mov bh,1
mov rotate_state,bh


ret


cannot_transform:
ret


transform_I_block_2:

cmp can_transform_var,1
je cannot_transform


call remove_block

mov ax,current_x_left_border
mov dx,current_x_right_border
mov cx,current_y_lower_bound
mov bx,current_y_upper_bound


sub dx,ax
sub cx,bx

mov bx,current_y_upper_bound
add bx,dx
mov current_y_lower_bound,bx

mov bx,current_x_left_border
add bx,cx
mov current_x_right_border,bx

mov bh,0
mov rotate_state,bh
ret





can_transform:


mov ax,current_x_left_border
mov dx,current_x_right_border
mov cx,current_y_lower_bound
mov bx,current_y_upper_bound
mov old_x_right_border,dx
mov old_x_left_border,ax
mov old_y_lower_bound,cx
mov old_y_upper_bound,bx
mov ax,old_x_left_border
mov dx,old_x_right_border
mov cx,old_y_lower_bound
mov bx,old_y_upper_bound

sub dx,ax
sub cx,bx

mov bx,old_y_upper_bound
add bx,dx
mov old_y_lower_bound,bx

mov bx,old_x_left_border
add bx,cx
mov old_x_right_border,bx



mov cx,current_x_right_border
inc cx
mov dx,old_y_upper_bound

transform_1_loop:
mov ah,0dh
mov bh,00h
int 10h



cmp al,00h
jne cant_transform_1


inc cx
cmp cx,old_x_right_border
jg increment_y_y



jmp transform_1_loop


increment_y_y:
mov cx,current_x_right_border
inc cx
inc dx
cmp dx, old_y_lower_bound
jg transform_1_end


jmp transform_1_loop




transform_1_end:
mov cl,0
mov can_transform_var,cl
ret


cant_transform_1:
mov cl,1
mov can_transform_var,cl 
ret



can_transform_2:


mov ax,current_x_left_border
mov dx,current_x_right_border
mov cx,current_y_lower_bound
mov bx,current_y_upper_bound
mov old_x_right_border,dx
mov old_x_left_border,ax
mov old_y_lower_bound,cx
mov old_y_upper_bound,bx
mov ax,old_x_left_border
mov dx,old_x_right_border
mov cx,old_y_lower_bound
mov bx,old_y_upper_bound

sub dx,ax
sub cx,bx


mov bx,current_x_left_border
add bx,cx
mov old_x_right_border,bx


mov bx,current_x_right_border
sub bx,old_x_right_border

mov ax,current_y_lower_bound
add ax,bx

mov old_y_lower_bound,ax




mov dx,current_y_lower_bound
inc dx
mov cx,current_x_left_border




transform_2_loop:
mov ah,0dh
mov bh,00h
int 10h



cmp al,00h
jne cant_transform_2


inc cx
cmp cx,old_x_right_border
jg increment_y_pos



jmp transform_2_loop


increment_y_pos:
mov cx,current_x_left_border
inc dx
cmp dx, old_y_lower_bound
jg transform_2_end


jmp transform_2_loop




transform_2_end:
mov cl,0
mov can_transform_var,cl
ret


cant_transform_2:
mov cl,1
mov can_transform_var,cl 
ret




remove_block:

mov dx,current_y_upper_bound
mov cx,current_x_left_border

remove_previous_block_4:
mov ah,0cH
mov al,000h
mov bh,00h
int 10h
inc cx

cmp cx,current_x_right_border
jg increment_y_7

jmp remove_previous_block_4


increment_y_7:
mov cx,current_x_left_border
inc dx
cmp dx,current_y_lower_bound
je remove_previous_end_4
jmp remove_previous_block_4



remove_previous_end_4:
mov cl,1
mov rotate_state,cl
ret




up_arrow equ 48h      
esc_key equ 1Bh       
down_arrow equ 50h     
left_arrow equ 4Bh    
right_arrow equ 4Dh  




program ends
end start

